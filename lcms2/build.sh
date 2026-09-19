#!/bin/bash
set -e
name=lcms2
repo=mm2/Little-CMS
version=$(gh_ver $repo)
depends=(glibc libjpeg-turbo libwebp tiff xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "${name/2/}$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
