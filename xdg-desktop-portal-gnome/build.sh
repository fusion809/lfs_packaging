#!/bin/bash
set -e
name=xdg-desktop-portal-gnome
homepage="https://gitlab.gnome.org/GNOME/xdg-desktop-portal-gnome"
description="Backend implementation for xdg-desktop-portal for GNOME."
version=$(gn_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(brotli bzip2 cairo elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin gnome-desktop graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz icu libadwaita libdrm libepoxy libffi libglvnd libgudev libjpeg-turbo libpng libseccomp libunwind libwebp libx11 libxau libxcb libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender mesa nautilus orc pango pcre2 pixman systemd tiff util-linux vulkan-loader wayland xdg-desktop-gtk xdg-desktop-portal xz zlib zstd)
gn_download "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
