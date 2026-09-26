#!/bin/bash
set -e
# Variable declaration
name=libhandy
description="GTK 3 UI elements for mobile devices"
homepage="https://gitlab.gnome.org/GNOME/libhandy"
version=$(gn_ver libhandy)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
depends=(at-spi2-core brotli bzip2 cairo dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 gtk3 harfbuzz lcms2 libepoxy libffi libpng libseccomp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxrandr libxrender libxres pango pcre2 pixman systemd util-linux vala wayland webkitgtk zlib)
# Fetch source and unpack it
gn_download "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
meson_options=(
	--prefix=/usr       \
    --buildtype=release
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
