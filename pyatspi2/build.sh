#!/bin/bash
set -e
name=pyatspi2
_name=$(echo $name | sed 's/2//g')
version=$(gn_ver $name)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
depends=(pygobject)
blfs_depends=(dbus-python)
filename="$_name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/$_name/$majVer/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
