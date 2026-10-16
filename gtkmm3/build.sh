#!/bin/bash
set -e
name=gtkmm3
_name=gtkmm
repo=GNOME/$_name
homepage="https://github.com/GNOME/gtkmm"
description="Provides a C++ interface to GTK+ 3."
depends=(at-spi2-core atkmm16 brotli bzip2 cairo cairomm10 dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glibmm24 glycin graphite2 gtk3 harfbuzz libepoxy libffi libpng libseccomp libselinux libsigcpp2 libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxrandr libxrender libxres pango pangomm14 pcre2 pixman systemd util-linux wayland zlib)
version=$(gh_ver $repo $name)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release -D maintainer-mode=true -D build-documentation=false
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
