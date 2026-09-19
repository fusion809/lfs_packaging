#!/bin/bash
set -e
name=gsound
version=$(gn_ver $name)
depends=(glib2 glibc libcanberra libffi libogg libvorbis pcre2 systemd util-linux webkitgtk zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(
	--prefix=/usr \
	--buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
