#!/bin/bash
set -e
name=pyatspi2
_name=$(echo $name | sed 's/2//g')
version=$(gn_ver $name)
depends=(dbus-python pygobject)
filename="$_name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
