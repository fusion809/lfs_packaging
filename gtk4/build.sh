#!/bin/bash
set -e
name=gtk4
_name=gtk
version=$(gn_ver $_name $name)
filename="$_name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(adwaita-icon-theme gdk-pixbuf glslc graphene gst-plugins-bad gst-plugins-good hicolor-icon-theme iso-codes libepoxy librsvg libxkbcommon pango pygobject vulkan-loader wayland-protocols xdg-desktop-portal xdg-desktop-portal-gnome)
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
