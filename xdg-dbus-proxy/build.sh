#!/bin/bash
set -e
name=xdg-dbus-proxy
source ~/lfs_packaging/shared-funcs.sh
version=$(github_ver flatpak/$name)
blfs_depends=(glib2)
direname="$name-$version"
filename="$direname.tar.xz"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/flatpak/xdg-dbus-proxy/releases/download/$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
mkdir build &&
cd    build &&

meson setup --prefix=/usr --buildtype=release -D man=disabled .. &&
ninja -j$(nproc)
sudo ninja install
cd ../..
rm -rf $direname $filename
echo "$version" > /var/lib/custom-packages/$name
