#!/bin/bash
set -e
name=xdg-desktop-portal
repo=flatpak/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(bubblewrap dbus docutils fuse gdk-pixbuf json-glib pipewire xdg-desktop-portal-gnome)
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release -D tests=disabled
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
