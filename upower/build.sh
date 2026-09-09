#!/bin/bash
set -e
name=upower
repo=$name/$name
version=$(gfd_ver $repo)
depends=(glib2 glibc libffi libgudev pcre2 polkit systemd util-linux zlib)
filename="$name-v$version.tar.bz2"
direname="${filename/.tar.*/}"
# Kernel options required
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.freedesktop.org/upower/upower/-/archive/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr       \
      --buildtype=release \
      -D gtk-doc=false    \
      -D man=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
