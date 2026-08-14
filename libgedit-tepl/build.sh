#!/bin/bash
set -e
# Variable declaration
name=libgedit-tepl
version=$(lgd_ver $name)
lfs_depends=(glibc
	gcc
	systemd
	zlib)
blfs_depends=(cairo
	exempi
	gdk-pixbuf
	glib
	gnome-desktop
	gtk3
	hicolor-icon-theme
	lcms
	libhandy
	libx11
	meson)
# Fetch source and unpack it
repo_url=https://gitlab.gnome.org/World/gedit/$name.git
if [[ ! -d "$name" ]]; then
	git clone --depth 1 --branch "$version" --recurse-submodules --shallow-submodules \
		$repo_url
fi

git -C "$name" remote set-url origin "$repo_url"
git -C "$name" fetch --prune --tags --depth=1 origin
git -C "$name" checkout --force --detach "$version"
git -C "$name" submodule sync --recursive
git -C "$name" submodule update --init --recursive --depth=1

# Compile and install
cd "$name"
sudo rm -rf build
mkdir build
cd build
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
meson setup --prefix=/usr       \
            --buildtype=release \
            -D gtk_doc=false    \
	    ..
ninja -j$(nproc)
sudo ninja install
# Cleanup and add to database
cd ..
echo $version > /var/lib/custom-packages/$name
