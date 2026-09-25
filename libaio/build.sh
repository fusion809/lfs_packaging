#!/bin/bash
set -e
name=libaio
homepage="https://pagure.io/libaio"
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local git_ver=$(timeout 5 git ls-remote --tags --refs $homepage.git | grep "refs/tags/libaio-[0-9.]+$" -oE | cut -d '-' -f 2)
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
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://releases.pagure.org/libaio/$filename"
unpk_enter "$filename" "$direname"
sed -i '/install.*libaio.a/s/^/#/' src/Makefile
maki
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
