#!/bin/bash
set -e
name=libfyaml
repo=pantoniou/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(gcc glibc icu libffi libxml2 libyaml zlib zstd)
blfs_depends=(llvm)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/pantoniou/libfyaml/releases/download/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --disable-static --without-libclang
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
