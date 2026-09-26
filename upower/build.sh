#!/bin/bash
set -e
name=upower
homepage="https://upower.freedesktop.org"
description="Abstraction for enumerating power devices, listening to device events and querying history and statistics"
repo=$name/$name
version=$(gfd_ver $repo)
depends=(glib2 glibc libffi libgudev pcre2 polkit systemd util-linux zlib)
filename="$name-v$version.tar.bz2"
direname="${filename/.tar.*/}"
# Kernel options required
gfd_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
options=(--prefix=/usr       \
      --buildtype=release \
      -D gtk-doc=false    \
      -D man=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
