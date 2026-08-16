#!/bin/bash
name=gnome-browser-connector
version=$(gn_ver $name)
lfs_depends=(python meson)
blfs_depends=(pygobject gnome-shell glib2 git)
depends=(libarchive)
if ! [[ -d $name ]]; then
	git clone https://gitlab.gnome.org/GNOME/gnome-browser-connector
fi

cd $name
git checkout v$version
meson_options=(
    --prefix=/usr
)
mni "${meson_options[@]}"
cd ..
rm -rf build
echo "$version" > /var/lib/custom-packages/$name
