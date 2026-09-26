#!/bin/bash
set -e
name=mtdev
homepage="https://bitmath.org/code/mtdev/"
description="A stand-alone library which transforms all variants of kernel MT events to the slotted type B protocol"
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://bitmath.se/org/git/mtdev.git | grep -oE "[0-9.]+$" | sort -V | tail -n 1)
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
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
download_src "https://bitmath.org/code/mtdev/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
