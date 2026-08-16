#!/bin/bash
set -e
name=xdg-dbus-proxy
version=$(gh_ver flatpak/$name)
blfs_depends=(glib2)
lfs_depends=(glibc libffi util-linux zlib)
depends=(glib2 pcre2)
direname="$name-$version"
filename="$direname.tar.xz"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/flatpak/xdg-dbus-proxy/releases/download/$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
mni --prefix=/usr --buildtype=release -D man=disabled
cd ../..
rm -rf $direname $filename
echo "$version" > /var/lib/custom-packages/$name
