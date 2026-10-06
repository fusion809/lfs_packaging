#!/bin/bash
set -e
name=pipewire
description="Low-latency audio/video router and processor."
homepage="https://pipewire.org"
repo=$name/$name
version=$(gfd_ver $repo)
depends=(alsa-lib avahi bluez bzip2 dbus elfutils fdk-aac fftw flac gcc glib2 glibc gst-plugins-base gstreamer jack lame libcanberra libdrm libffi libogg libsndfile libtool libunwind libusb libvorbis libx11 libxau libxcb libxdmcp libxfixes mpg123 ncurses openssl opus orc pcre2 pulseaudio readline sbc systemd util-linux xz zlib zstd)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
gfd_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
meson_options=(
	--prefix=/usr \
	--buildtype=release \
	-D session-managers="[]")
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
