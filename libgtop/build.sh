#!/bin/bash
set -e
name=libgtop
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(glib2 glibc libffi libxau pcre2)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(--prefix=/usr --disable-static)
cmi "${options[@]}"
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
