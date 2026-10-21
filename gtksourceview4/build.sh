#!/bin/bash
set -e
name=gtksourceview4
_name=gtksourceview
repo=GNOME/$_name
homepage="https://wiki.gnome.org/Projects/GtkSourceView"
description="Extends GTK+ text functions to include syntax highlighting."
version=$(gh_ver $repo $name)
depends=(at-spi2-core brotli bzip2 cairo dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 gtk3 harfbuzz icu libepoxy libffi libpng libseccomp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender libxres pango pcre2 pixman ssw systemd util-linux wayland zlib)
filename="$_name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../.
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
