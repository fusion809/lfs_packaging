#!/bin/bash
set -e
name=power-profiles-daemon
version=$(wget -cqO- https://gitlab.freedesktop.org/upower/power-profiles-daemon/-/tags | grep "/tags/" | head -n 1 | cut -d '"' -f 2 | cut -d '/' -f 6)
filename="$name-$version.tar.gz"
direname="$name-$version"
blfs_depends=(polkit pygobject upower)
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.freedesktop.org/upower/power-profiles-daemon/-/archive/$version/$filename
fi

rm -rf "$direname"
tar xf "$filename"
cd "$direname"
mkdir build &&
cd build &&

meson setup                \
      --prefix=/usr        \
      --buildtype=release  \
      -D gtk_doc=false     \
      -D tests=false       \
      .. &&
      ninja -j$(nproc)
sudo ninja install
cd ../..
rm -rf "$direname" "$filename"

echo "$version" > /var/lib/custom-packages/$name
