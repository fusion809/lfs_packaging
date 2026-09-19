#!/bin/bash
set -e
name=pygobject
version=$(gn_ver pygobject)
majVer=$(echo $version | sed 's/.[0-9]$//g')
depends=(glib2 pycairo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gn_download "$filename"

unpk_enter "$filename" "$direname"
options=(--prefix=/usr \
	--buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf $direname $filename
echo "$version" | sudo tee /var/lib/custom-packages/$name
