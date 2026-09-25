#!/bin/bash
set -e
name=nspr
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://archive.mozilla.org/pub/nspr/releases/ | grep -E "/releases/v[0-9.]+" | sed 's|.*/releases/v||g' | cut -d '/' -f 1 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local gentoo_ver=$(gent_ver dev-libs/nspr)
	ver_check "$gentoo_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver" && return
}
version=$(get_version)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="$name-$version"
download_src "https://archive.mozilla.org/pub/nspr/releases/v$version/src/$filename"
unpk_enter "$filename" "$direname" "nspr"
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
