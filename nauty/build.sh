#!/bin/bash
set -e
name=nauty
get_version() {
	local up_ver=$(wget -cqO- -T 5 -t 1 https://pallini.di.uniroma1.it/ | grep "CURRENT VERSION: [0-9_]+" -oE | sed 's/CURRENT VERSION: //g' | tr '_' '.')
	local inst_ver=$(pkgver $name)
	local arch_ver=$(aver $name)
	ver_check "$up_ver" "$inst_ver" "$arch_ver" && return
	fver "$name" "$inst_ver"
}
homepage="http://pallini.di.uniroma1.it/"
description="Program for computing automorphism of graphs/digraphs."
version=$(get_version)
filename="${name}${version//./_}.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://pallini.di.uniroma1.it/$filename"
unpk_enter "$filename" "$direname"
CFLAGS="$CFLAGS $LDFLAGS" \
cmi --prefix=/usr --disable-static --includedir=/usr/include/$name --enable-generic
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
