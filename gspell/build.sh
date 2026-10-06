#!/bin/bash
set -e
name=gspell
description="Spell-checking library for GTK applications."
homepage="https://gitlab.gnome.org/GNOME/gspell"
version=$(gn_ver gspell)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(at-spi2-core brotli bzip2 cairo dbus enchant expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz icu libepoxy libffi libpng libseccomp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxrandr libxrender libxres pango pcre2 pixman systemd util-linux wayland zlib)
gn_download "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release -D gtk_doc=false
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
