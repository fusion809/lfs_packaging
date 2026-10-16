#!/bin/bash
set -e
name=atkmm
repo=GNOME/$name
homepage="https://github.com/GNOME/atkmm"
description="C++ interface for the ATK accessibility toolkit library."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(dbus glib2 gsettings-desktop-schemas)
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release -D maintainer-mode=true -D build-documentation=false
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
