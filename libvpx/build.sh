#!/bin/bash
set -e
name=libvpx
repo="webmproject/$name"
version=$(gh_ver $repo)
depends=(nasm which yasm)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
find -type f | xargs touch
sed -i 's/cp -p/cp/' build/make/Makefile &&
cmi --prefix=/usr --enable-shared --disable-static
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
