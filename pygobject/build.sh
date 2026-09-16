#!/bin/bash
set -e
name=pygobject
version=$(gn_ver pygobject)
majVer=$(echo $version | sed 's/.[0-9]$//g')
depends=(glib2 pycairo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.gnome.org/sources/pygobject/$majVer/$filename
fi

rm -rf $direname
tar xf $filename
cd $direname
options=(--prefix=/usr \
	--buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf $direname $filename
echo "$version" | sudo tee /var/lib/custom-packages/$name
