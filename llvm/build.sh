#!/bin/bash
set -e
name=llvm
repo=$name/$name
version=$(gh_ver $repo)
depends=(gcc glibc icu libffi libxml2 zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/releases/download/$direname/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
