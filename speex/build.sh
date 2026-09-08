#!/bin/bash
set -e
name=speex
repo=xiph/$name
version=$(gh_ver $repo)
depends=(glibc libogg)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://downloads.xiph.org/releases/speex/$filename
fi
dsp_filename="speexdsp-$version.tar.gz"
dsp_direname="${dsp_filename/.tar.*/}"
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --disable-static --docdir=/usr/share/doc/$direname
cd ../
tar xf $dsp_filename
cd $dsp_direname
options=(--prefix=/usr    \
            --disable-static \
	    --docdir=/usr/share/doc/$dsp_direname)
cmi "${options[@]}"
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
