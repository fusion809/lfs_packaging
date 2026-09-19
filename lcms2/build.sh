#!/bin/bash
set -e
name=lcms2
repo=mm2/Little-CMS
version=$(gh_ver $repo)
depends=(glibc libjpeg-turbo libwebp tiff xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/${name/2/}$version/$filename
fi
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
