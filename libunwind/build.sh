#!/bin/bash
set -e
name=libunwind
repo=$name/$name
version=$(gh_ver $repo)
depends=(gcc glibc xz zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/releases/download/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i '/func.s/s/s//' tests/Gtest-nomalloc.c
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
