#!/bin/bash
set -e
name=pipewire
repo=$name/$name
version=$(gfd_ver $repo)
depends=(alsa-lib avahi bluez dbus fdk-aac flac gcc glib2 glibc jack lame libcanberra libffi libogg libsndfile libtool libusb libvorbis libx11 libxau libxcb libXdmcp libXfixes mpg123 ncurses openssl opus pcre2 pulseaudio readline sbc systemd util-linux zlib)
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
