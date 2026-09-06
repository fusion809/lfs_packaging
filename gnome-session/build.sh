#!/bin/bash
set -e
name=gnome-session
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 expat fontconfig freetype gcc gdk-pixbuf glib2 glibc glycin gnome-desktop icu libffi libpng libxkbcommon libxml2 pcre2 systemd util-linux zlib)
blfs_depends=(lcms2 libseccomp)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr --buildtype=release -D man=false        \
            -D docbook=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
