#!/bin/bash
set -e
name=xdg-desktop-portal-gtk
homepage="https://github.com/flatpak/xdg-desktop-portal-gtk"
description="Backend implementation for xdg-desktop-portal using GTK."
repo=flatpak/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(at-spi2-core brotli bzip2 cairo dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin gnome-desktop graphite2 gtk3 harfbuzz icu libepoxy libffi libpng libseccomp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender libxres pango pcre2 pixman systemd util-linux wayland xdg-desktop-portal zlib)
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
