#!/bin/bash
set -e
name=libgee
homepage="https://gitlab.gnome.org/GNOME/libgee"
description="A collection library providing GObject-based interfaces and classes for commonly used data structures"
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(glib2 glibc libffi pcre2 systemd util-linux zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(--prefix=/usr --enable-vala)
cmi "${options[@]}"
cd .. 
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
