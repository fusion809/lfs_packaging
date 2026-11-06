#!/bin/bash
set -e
name=libcdio
homepage="https://www.gnu.org/software/libcdio/"
description="GNU Compact Disc Input and Control Library."
repo=libcdio/libcdio-C
version=$(gh_ver $repo "$name")
pr_version=$(wget -T 10 -t 2 -qO- https://ftp.gnu.org/gnu/libcdio/ 2>/dev/null | grep -oE 'libcdio-paranoia-[0-9.]+([+][0-9.]+)?\.tar\.bz2' | sed -E 's/libcdio-paranoia-(.*)\.tar\.bz2/\1/' | sort -V | tail -n 1)
[[ -n "$pr_version" ]] || pr_version="10.2+2.0.2"
pr_filename="libcdio-paranoia-$pr_version.tar.bz2"
pr_direname="${pr_filename/.tar.*/}"
depends=(gcc glibc ncurses)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$version" "$filename"
download_src "https://ftp.gnu.org/gnu/libcdio/$pr_filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
tar -xf ../$pr_filename &&
cd $pr_direname &&
cmi --prefix=/usr --disable-static &&
cd ../..
rm -rf "$filename" "$direname" "$pr_filename"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
