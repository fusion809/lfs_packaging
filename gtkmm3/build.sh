#!/bin/bash
set -e
name=gtkmm3
_name=gtkmm
repo=GNOME/$_name
homepage="https://github.com/GNOME/gtkmm"
description="Provides a C++ interface to GTK+ 3."
depends=(atkmm glibmm24 pangomm gtk3)
version=$(gh_ver $repo $name)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release -D maintainer-mode=true -D build-documentation=false -D'cairomm-1.0:build-documentation'=false -D'pangomm-1.4:build-documentation'=false
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
