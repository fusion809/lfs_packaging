#!/bin/bash
set -e
name=gst-plugins-bad
homepage="https://gstreamer.freedesktop.org/"
description="Multimedia graph framework - bad plugins."
version=$(gfd_ver gstreamer/gstreamer)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(at-spi2-core brotli bzip2 cairo curl cyrus-sasl dav1d dbus elfutils expat fdk-aac flac fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gst-plugins-base gstreamer gtk3 harfbuzz icu json-glib lame lcms2 libaom libass libde265 libdrm libdvdnav libdvdread libepoxy libffi libglvnd libgudev libidn2 libogg libpng libpsl libqrencode librsvg libseccomp libsndfile libunistring libunwind libusb libva libvorbis libwebp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender libxres mesa mpg123 nettle nghttp2 numactl openjpeg openldap openssl opus orc pango pcre2 pixman sbc soundtouch svt-av1 systemd util-linux vulkan-loader wayland xdg-desktop-portal-kde xz zlib zstd zxing-cpp)
download_src "https://gstreamer.freedesktop.org/src/gst-plugins-bad/$filename"
unpk_enter "$filename" "$direname"
meson_options=(--prefix=/usr       \
      --buildtype=release \
      -D gpl=enabled)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
