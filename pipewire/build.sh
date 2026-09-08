#!/bin/bash
set -e
name=pipewire
repo=$name/$name
version=$(gfd_ver $repo)
depends=(bluez dbus flac gcc glib2 glibc jack libX11 libXau libXdmcp libXfixes libffi libtool libusb libxcb ncurses openssl pcre2 pulseaudio readline sbc systemd util-linux zlib)
blfs_depends=(alsa-lib avahi fdk-aac lame libcanberra libogg libsndfile libvorbis mpg123 opus)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.freedesktop.org/pipewire/pipewire/-/archive/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
meson_options=(--prefix=/usr                   --buildtype=release 	    -D session-managers="[]")
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
