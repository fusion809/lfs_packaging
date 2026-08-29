#!/bin/bash
set -e
name=pygobject
version=$(gn_ver pygobject)
majVer=$(echo $version | sed 's/.[0-9]$//g')
depends=(pycairo glib2)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/pygobject/$majVer/$filename
fi

rm -rf $direname
tar xf $filename
cd $direname
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf $direname $filename
echo "$version" > /var/lib/custom-packages/$name
