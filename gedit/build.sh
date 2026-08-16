#!/bin/bash
set -e
# Variable declaration
name=gedit
version=$(gn_ver $name)
lfs_depends=(bzip2 dbus expat gcc glibc libffi systemd util-linux zlib)
blfs_depends=(at-spi2-core brotli cairo enchant exempi fontconfig freetype fribidi gdk-pixbuf glib glycin gnome-desktop graphite2 gspell gtk3 harfbuzz hicolor-icon-theme lcms lcms2 libXau libXdmcp libepoxy libhandy libpeas libpng libseccomp libx11 libxcb libxkbcommon libxml2 meson pixman webkitgtk)
depends=(glib2 gtk3 libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXres libgedit-amtk libgedit-gfls libgedit-gtksourceview libgedit-tepl pango pcre2 wayland)
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
