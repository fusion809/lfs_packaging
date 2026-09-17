#!/bin/bash
set -e
name=speex
repo=xiph/$name
version=$(gh_ver $repo)
depends=(glibc libogg)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://downloads.xiph.org/releases/speex/$filename"
dsp_filename="speexdsp-$version.tar.gz"
dsp_direname="${dsp_filename/.tar.*/}"
download_src "https://downloads.xiph.org/releases/speex/$dsp_filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static --docdir=/usr/share/doc/$direname
cd ../
unpk_enter "$dsp_filename" "$dsp_direname"
options=(
	--prefix=/usr    \
    --disable-static \
	--docdir=/usr/share/doc/$dsp_direname
)
cmi "${options[@]}"
cd ..
rm -rf "$filename" "$direname" "$dsp_filename" "$dsp_direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
