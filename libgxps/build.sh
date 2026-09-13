#!/bin/bash
set -e
name=libgxps
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(acl brotli bzip2 cairo expat fontconfig freetype gcc glib2 glibc icu lcms2 libX11 libXau libXdmcp libXext libXrender libarchive libffi libjpeg-turbo libpng libwebp libxcb libxml2 lz4 openssl pcre2 pixman systemd tiff util-linux xz zlib zstd)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr --buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
