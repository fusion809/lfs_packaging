#!/bin/bash
set -e
name=libportal
homepage="https://github.com/flatpak/libportal"
description="GIO-style async APIs for most Flatpak portals."
repo=flatpak/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(at-spi2-core brotli bzip2 cairo dbus double-conversion elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk3 gtk4 harfbuzz icu libdrm libepoxy libffi libglvnd libgudev libjpeg-turbo libpng libseccomp libunwind libwebp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxrandr libxrender libxres mesa openssl orc pango pcre2 pixman qt6 systemd tiff util-linux vulkan-loader wayland xdg-desktop-portal-gnome xz zlib zstd)
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
#gap_patches $name
sed -i "s/requires: \[qt6_dep/requires: ['Qt6Core', 'Qt6Gui', 'Qt6Widgets'/" libportal/meson.build
export PKG_CONFIG_PATH="/opt/qt6/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
meson_options=(--prefix=/usr       \
            --buildtype=release \
            -D vapi=false       \
	    -D docs=false)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
