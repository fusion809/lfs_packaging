#!/bin/bash
set -e
name=xorgproto
type=$(get_xfd_type $name)
version=$(xfd_ver $type $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
xfd_download "$name" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr
sudo mv -v /usr/share/doc/$name{,-$version}
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
