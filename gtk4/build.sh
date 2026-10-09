#!/bin/bash
set -e
name=gtk4
description="GObject-based multi-platform GUI toolkit."
_name=gtk
repo=GNOME/$_name
homepage="https://www.gtk.org"
version=$(gh_ver $repo $_name)
filename="$_name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(adwaita-icon-theme brotli bzip2 cairo elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glslc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gst-plugins-good gstreamer harfbuzz hicolor-icon-theme iso-codes libdrm libepoxy libffi libglvnd libgudev libjpeg-turbo libpng librsvg libseccomp libunwind libwebp libx11 libxau libxcb libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxrandr libxrender mesa orc pango pcre2 pixman pygobject systemd tiff util-linux vulkan-loader wayland wayland-protocols xdg-desktop-portal xdg-desktop-portal-gnome xz zlib zstd)
# Requires userspace dmabuf misc driver from kernel
gn_download "$filename"
unpk_enter "$filename" "$direname"
meson_options=(--prefix=/usr            \
            --buildtype=release      \
            -D broadway-backend=true \
            -D introspection=enabled \
            -D vulkan=enabled)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
