#!/bin/bash
set -e
name=glibmm
repo=GNOME/$name
homepage="https://github.com/GNOME/glibmm"
description="Set of C++ bindings for GLib."
depends=(gcc glib2 glibc libffi libselinux pcre2 systemd util-linux zlib)
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$dirname"
mni --prefix=/usr --buildtype=release -D build-documentation=false -D maintainer-mode=true -D'sigc++-3.0:build-documentation'=false
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
