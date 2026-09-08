#!/bin/bash
set -e
name=desktop-file-utils
repo=PCMan/$name
version=$(gh_ver $repo)
depends=(glib2 glibc libffi pcre2 systemd util-linux zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.freedesktop.org/software/desktop-file-utils/releases/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
