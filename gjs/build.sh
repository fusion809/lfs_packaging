#!/bin/bash
set -e
name=gjs
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 expat fontconfig freetype gcc glib2 glibc icu libX11 libXext libXrender libffi libpng ncurses pcre2 readline systemd util-linux zlib)
blfs_depends=(cairo libXau libXdmcp libxcb pixman)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr --buildtype=release --wrap-mode=nofallback)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
