#!/bin/bash
set -e
name=zip
description="Compressor/archiver for creating and modifying zipfiles."
homepage="http://www.info-zip.org/Zip.html"
get_version() {
	local inst_ver=$(pkgver $name)
	local arch_ver=$(aver $name)
	local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$arch_ver" && return
	local nix_ver=$(nixver $name)
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$nix_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(bzip2 glibc)
filename="${name}${version/./}.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://downloads.sourceforge.net/infozip/$filename"
unpk_enter "$filename" "$direname"
make -f unix/Makefile generic CC="gcc -std=gnu89"
sudo make prefix=/usr MANDIR=/usr/share/man/man1 -f unix/Makefile install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
