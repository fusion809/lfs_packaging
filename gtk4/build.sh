#!/bin/bash
set -e
name=gtk4
_name=gtk
version=$(gn_ver $_name $name)
majVer=$(echo $version | sed -E 's/.[0-9]+$//g')
filename="$_name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gdk-pixbuf graphene iso-codes libepoxy librsvg libxkbcommon pango pygobject wayland-protocols adwaita-icon-theme gst-plugins-bad glslc gst-plugins-good hicolor-icon-theme vulkan-loader xdg-desktop-portal xdg-desktop-portal-gnome)
# Requires userspace dmabuf misc driver from kernel
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/gtk/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
meson_options=(--prefix=/usr            \
            --buildtype=release      \
            -D broadway-backend=true \
            -D introspection=enabled \
            -D vulkan=enabled)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
