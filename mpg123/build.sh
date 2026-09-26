#!/bin/bash
set -e
name=mpg123
homepage="https://mpg123.de/"
description="Console based real time MPEG Audio Player for Layer 1, 2 and 3"
repo=libsdl-org/$name
version=$(gh_ver $repo)
depends=(alsa-lib dbus flac gcc glibc jack lame libogg libsndfile libvorbis libxau libxcb libxdmcp opus portaudio pulseaudio sdl2-compat systemd)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
sf_dowload "$name" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
