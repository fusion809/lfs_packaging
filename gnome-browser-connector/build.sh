#!/bin/bash
name=gnome-browser-connector
version=$(git ls-remote --tags --refs https://gitlab.gnome.org/GNOME/gnome-browser-connector.git | awk '{print $2}' | sed 's|refs/tags/||' | sed 's/^v//g' | sort -V | tail -n1)
lfs_depends=(python meson)
blfs_depends=(pygobject gnome-shell glib2 git)
depends=(libarchive) # Required to actually install extensions
# libarchive provided by BLFS doesn't work due to bsdunzip incompatibility with
# info-zip unzip commands
if ! [[ -d $name ]]; then
	git clone https://gitlab.gnome.org/GNOME/gnome-browser-connector
fi

cd $name
git checkout v$version
mkdir build
cd build
meson setup --prefix=/usr
ninja -j$(nproc)
sudo ninja install
cd ..
rm -rf build
echo "$version" > /var/lib/custom-packages/$name
