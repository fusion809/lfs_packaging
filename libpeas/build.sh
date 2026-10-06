#!/bin/bash
set -e 
name=libpeas
#homepage="https://gitlab.gnome.org/GNOME/libpeas"
homepage="https://wiki.gnome.org/Projects/Libpeas"
description="GObject Plugin System."
version=$(gn_ver libpeas)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(at-spi2-core brotli bzip2 cairo dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz libepoxy libffi libpng libseccomp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxrandr libxrender libxres pango pcre2 pixman systemd util-linux wayland zlib)
gn_download "$filename"
unpk_enter "$filename" "$direname"
meson_options=(
    --prefix=/usr          \
    --buildtype=release    \
    --wrap-mode=nofallback \
	-D python3=false)
mni "${meson_options[@]}"
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
