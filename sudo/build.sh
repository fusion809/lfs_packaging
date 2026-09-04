#!/bin/bash
set -e
name=sudo
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://www.sudo.ws/dist | grep -E "[0-9.]+\.tar\.gz" | sed 's/.*sudo-//g' | sed 's/\.tar\.gz.*//g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/sudo-project/sudo.git | sed 's/.*v//g' | grep -E "^[0-9.p]+$" | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$name-$version.tar.gz"
direname="$name-$version"
if ! [[ -f $filename ]]; then
	wget -c https://www.sudo.ws/dist/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
sed -e 's/\([->.a-zA-Z_]*\)->length/ASN1_STRING_length(\1)/' \
    -i lib/iolog/hostcheck.c
configure_options=(--prefix=/usr         \
            --libexecdir=/usr/lib \
            --with-secure-path    \
            --with-env-editor     \
            --docdir=/usr/share/doc/$direname \
	    --with-passprompt="[sudo] password for %p: ")
cmi "${configure_options[@]}"
cd ..
rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
