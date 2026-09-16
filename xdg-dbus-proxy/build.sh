#!/bin/bash
set -e
name=xdg-dbus-proxy
version=$(gh_ver flatpak/$name)
depends=(glib2 glib2 glibc libffi pcre2 util-linux zlib)
direname="$name-$version"
filename="$direname.tar.xz"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/flatpak/xdg-dbus-proxy/releases/download/$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
mni --prefix=/usr --buildtype=release -D man=disabled
cd ../..
rm -rf $direname $filename
echo "$version" | sudo tee /var/lib/custom-packages/$name
