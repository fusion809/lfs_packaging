#!/bin/bash
set -e
name=zlib
get_up_ver() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://zlib.net/fossils | grep -E "zlib-[0-9]+\.[0-9]+" | cut -d '"' -f 4 | cut -d '-' -f 2 | sed 's/.tar.gz//g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(aver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
}
repo=malder/$name
version=$(get_up_ver || gh_ver $repo)
depends=(coreutils gcc glibc gzip make tar wget)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://zlib.net/fossils/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
sudo rm -fv /usr/lib/libz.a
cd ..
echo "$version" | sudo tee /var/lib/custom-packages/$name
