#!/bin/bash
set -e
name=mpg123
repo=libsdl-org/$name
version=$(gh_ver $repo)
depends=(alsa-lib dbus flac gcc glibc jack lame libogg libsndfile libvorbis libXau libxcb libXdmcp opus portaudio pulseaudio sdl2-compat systemd)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://downloads.sourceforge.net/mpg123/$filename
fi
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
