#!/bin/bash
set -e
name=glibmm24
_name=glibmm
repo=GNOME/$_name
homepage="https://github.com/GNOME/glibmm"
description="Set of C++ bindings for GLib."
version=$(gh_ver $repo $name)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release -D maintainer-mode=true -D build-documentation=false
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
