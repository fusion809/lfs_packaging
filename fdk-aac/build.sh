#!/bin/bash
set -e
name=fdk-aac
repo=mstorsjo/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://downloads.sourceforge.net/opencore-amr/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
