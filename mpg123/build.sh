#!/bin/bash
set -e
name=mpg123
repo=libsdl-org/$name
version=$(gh_ver $repo)
depends=(alsa-lib dbus flac gcc glibc jack lame libXau libXdmcp libxcb portaudio pulseaudio sdl2-compat systemd)
blfs_depends=(libogg libsndfile libvorbis opus)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://downloads.sourceforge.net/mpg123/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
