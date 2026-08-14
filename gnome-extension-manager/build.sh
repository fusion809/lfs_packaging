#!/bin/bash
name=gnome-extension-manager
_name=extension-manager
source ~/lfs_packaging/shared-funcs.sh
version=$(gh_ver mjakeman/$_name)
direname=$_name-$version
filename=$direname.tar.gz
lfs_depends=(gettext)
blfs_depends=(blueprint libxml2 libsoup libjson-glib libadwaita gtk4 glycin)

if ! [[ -f $filename ]]; then
	wget -c https://github.com/mjakeman/$_name/archive/refs/tags/v$version.tar.gz -O $filename
fi

rm -rf $direname
tar xf $filename
cd $direname
meson setup _build --prefix=/usr -D backtrace=false
meson compile -C _build
sudo meson install -C _build
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
