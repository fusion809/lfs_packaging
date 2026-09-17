#!/bin/bash
set -e
name=xdg-dbus-proxy
repo="flatpak/$name"
version=$(gh_ver $repo)
depends=(glib2 glib2 glibc libffi pcre2 util-linux zlib)
direname="$name-$version"
filename="$direname.tar.xz"
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release -D man=disabled
cd ../..
rm -rf $direname $filename
echo "$version" | sudo tee /var/lib/custom-packages/$name
