#!/bin/bash
set -e
name=cairo
repo=$name/$name
version=$(gfd_ver $repo)
depends=(brotli bzip2 expat fontconfig freetype glib2 glibc libX11 libXau libXdmcp libXext libXrender libffi libpng libxcb pcre2 zlib)
blfs_depends=(pixman)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.cairographics.org/releases/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
mni--prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
