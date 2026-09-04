#!/bin/bash
set -e
name=nspr
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://archive.mozilla.org/pub/nspr/releases/ | grep -E "/releases/v[0-9.]+" | sed 's|.*/releases/v||g' | cut -d '/' -f 1 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	local gentoo_ver=$(gent_ver dev-libs/nspr)
	ver_check "$gentoo_ver" "$inst_ver" && return
	fver "$name" "$inst_ver" && return
}
version=$(get_version)
filename="$name-$version.tar.gz"
direname="$name-$version"
if ! [[ -f $filename ]]; then
	wget -c https://archive.mozilla.org/pub/nspr/releases/v$version/src/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname/nspr
sed -i '/^RELEASE/s|^|#|' pr/src/misc/Makefile.in &&
sed -i 's|$(LIBRARY) ||'  config/rules.mk         &&
configure_options=(--prefix=/usr   \
            --with-mozilla  \
            --with-pthreads \
            --enable-64bit)
cmi "${configure_options[@]}"
cd ../..
rm -rf $direname $filename
echo "$version" | sudo tee /var/lib/custom-packages/$name
