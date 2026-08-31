#!/bin/bash
set -e 
name=libpeas
version=$(gn_ver libpeas)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
blfs_depends=(glib2 gtk3)
lfs_depends=(glibc)
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/libpeas/$majVer/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
meson_options=(--prefix=/usr          \
            --buildtype=release    \
            --wrap-mode=nofallback \
	    -D python3=false)
mni "${meson_options[@]}"
cd ../..
rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
