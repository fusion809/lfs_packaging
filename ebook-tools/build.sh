#!/bin/bash
set -e
name=ebook-tools
homepage="https://sourceforge.net/projects/ebook-tools"
get_version() {
	local inst_ver=$(pkgver $name)
	local mon_ver=$(uver $name)
	local up_ver=$(wget -cqO- -T 5 -t 1 $homepage/files/ebook-tools/ \
		| grep -oE "[0-9.]+/" | grep "\." | sed 's|/||g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$mon_ver" && return
	fver "$name" "$inst_ver"
}
description="Tools for accessing and converting various ebook file formats."
version=$(get_version)
depends=(bzip2 gcc glibc icu libxml2 libzip openssl xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
sf_download "$name" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
