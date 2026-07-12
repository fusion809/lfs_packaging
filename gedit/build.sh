#!/bin/bash
set -e
# Variable declaration
name=gedit
version="$(wget -cqO- https://gitlab.gnome.org/World/$name/$name/-/tags | grep "tags/"| grep -v "alpha\|beta\|\.rc" | grep "$(gnome-shell --version | cut -d ' ' -f 3 | cut -d '.' -f 1)" | cut -d '"' -f 2 | cut -d '/' -f 7)"
lfs_depends=(glibc
	gcc
	systemd
	zlzib)
blfs_depends=(cairo
	dconf
	exempi
	gdk-pixbuf
	glib
	gnome-desktop
	gspell
	gtk3
	hicolor-icon-theme
	lcms
	libexif
	libhandy
	libjpeg-turbo
	libpeas
	librsvg
	libx11
	meson)
depends=(libgedit-tepl
	libgedit-amtk
	libgedit-gtksourceview
	libgedit-gfls)
# Fetch source and unpack it
repo_url="https://gitlab.gnome.org/World/gedit/$name.git"
if [[ ! -d "$name/.git" ]]; then
	git clone --depth 1 --branch "$version" --recurse-submodules --shallow-submodules \
		"$repo_url" "$name"
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
