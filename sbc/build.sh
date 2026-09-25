#!/bin/bash
set -e
name=sbc
homepage="https://www.kernel.org/pub/linux/bluetooth/"
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- $homepage | grep "sbc-[0-9]+\.[0-9]+" -oE | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(glibc)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "$homepage/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static --disable-tester
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
