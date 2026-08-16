#!/bin/bash
set -e
# Variable declaration
name=libgedit-gfls
version=$(lgd_ver $name)
lfs_depends=(gcc glibc libffi systemd util-linux zlib)
depends=(glib2 pcre2)
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
repo_url="https://gitlab.gnome.org/World/gedit/$name.git"
if [[ ! -d "$name/.git" ]]; then
	git clone --depth 1 --branch "$version" --recurse-submodules --shallow-submodules \
		"$repo_url"
fi

git -C "$name" remote set-url origin "$repo_url"
git -C "$name" fetch --prune --tags --depth=1 origin
git -C "$name" checkout --force --detach "$version"
git -C "$name" submodule sync --recursive
git -C "$name" submodule update --init --recursive --depth=1

# Compile and install
cd "$name"
sudo rm -rf build
meson_options=(
	--prefix=/usr       \
    --buildtype=release \
    -D gtk_doc=false
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ..
echo $version > /var/lib/custom-packages/$name
