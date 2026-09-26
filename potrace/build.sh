#!/bin/bash
set -e
name=potrace
homepage="http://potrace.sourceforge.net/"
description="Utility for tracing a bitmap (input: PBM,PGM,PPM,BMP; output: EPS,PS,PDF,SVG,DXF,PGM,Gimppath,XFig)"
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -cqO- -T 5 -t 1 https://sourceforge.net/projects/potrace/files/ | grep "[0-9]+\.[0-9]+/" -oE | cut -d '/' -f 1 | sort -V | tail -n 1)
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
depends=(glibc zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
sf_download "$name" "$version" "$filename"
unpk_enter "$filename" "$direname"
options=(--prefix=/usr                        \
            --disable-static                     \
            --docdir=/usr/share/doc/$direname \
            --enable-a4                          \
            --enable-metric                      \
	    --with-libpotrace)
cmi "${options[@]}"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
