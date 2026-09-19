#!/bin/bash
set -e
name=pyatspi2
_name=$(echo $name | sed 's/2//g')
version=$(gn_ver $name)
depends=(dbus-python pygobject)
filename="$_name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.gnome.org/sources/$_name/$majVer/$filename
fi
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
