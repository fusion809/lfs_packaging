#!/bin/bash
set -e
[ -f /etc/profile ] && source /etc/profile
name=gnome-weather
repo=GNOME/$name
homepage="https://wiki.gnome.org/Apps/Weather"
description="Small application that provides local weather forecasts."
version=$(gn_ver $name)
major_ver="${version%%.*}"
filename="$name-$version.tar.xz"
direname="$name-$version"
gn_download "$filename"
unpk_enter "$filename" "$direname"
npm ci
PATH="$PWD/node_modules/.bin:$PATH"
options=(--prefix=/usr --buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
