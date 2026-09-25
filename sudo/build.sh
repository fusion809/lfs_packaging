#!/bin/bash
set -e
name=sudo
homepage="https://www.sudo.ws"
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- $homepage/dist | grep -E "[0-9.]+\.tar\.gz" | sed 's/.*sudo-//g' | sed 's/\.tar\.gz.*//g' | sort -V | tail -n 1)
	local lfs_vers=$(lfs_ver $name)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/sudo-project/sudo.git | sed 's/.*v//g' | grep -E "^[0-9.p]+$" | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(glibc linux-pam openssl zlib)
filename="$name-$version.tar.gz"
direname="$name-$version"
download_src "$homepage/dist/$filename"
unpk_enter "$filename" "$direname"
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
