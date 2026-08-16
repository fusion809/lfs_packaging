#!/bin/bash
set -e
# Variable declarations
name="wl-clipboard"
depends=(wayland)
lfs_depends=(bash coreutils glibc libffi meson ninja)
blfs_depends=(git wayland wayland-protocols)
# Fetch and unpack source
if ! [[ -d $name ]]; then
	git clone https://github.com/bugaevc/wl-clipboard
fi
cd $name
version=$(git pull origin master -q && git log | head -n 1 | cut -d ' ' -f 2)
# Compile and install
rm -rf build
meson_options=(
	--prefix=/usr       \
    --buildtype=release
)
mni "${meson_options[@]}"
cd ..
# Cleanup and add to database
rm -rf build
cd ..
echo $version > /var/lib/custom-packages/$name
