#!/bin/bash
set -e
name=gst-plugins-good
homepage="https://gstreamer.freedesktop.org/"
description="Multimedia graph framework - good plugins."
version=$(gfd_ver gstreamer/gstreamer)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(at-spi2-core brotli bzip2 cairo dbus double-conversion e2fsprogs elfutils expat flac fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gst-plugins-base gstreamer gtk3 harfbuzz icu keyutils lame libaom libdrm libdvdnav libdvdread libepoxy libffi libglvnd libgudev libjpeg-turbo libogg libpng libseccomp libsndfile libunwind libva libvorbis libvpx libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender libxres libxtst mesa mitkrb mpg123 nettle openssl opus orc pango pcre2 pixman pulseaudio qt6 soundtouch svt-av1 systemd taglib util-linux v4l-utils wayland xz zlib zstd)
download_src "https://gstreamer.freedesktop.org/src/gst-plugins-good/$filename"
unpk_enter "$filename" "$direname"
meson_options=(--prefix=/usr       \
	--buildtype=release)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
