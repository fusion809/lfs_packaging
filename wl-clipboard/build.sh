#!/bin/bash
set -e
# Variable declarations
name="wl-clipboard"
repo="bugaevc/wl-clipboard"
version=$(git ls-remote https://github.com/$repo.git HEAD | awk '{print $1}')
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(wayland)
lfs_depends=(bash coreutils glibc libffi meson ninja)
blfs_depends=(wayland wayland-protocols)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/${version}.tar.gz -O $filename
fi
tar xvf $filename
cd $direname
# Compile and install
meson_options=(
	--prefix=/usr       \
    --buildtype=release
)
mni "${meson_options[@]}"
cd ../..
# Cleanup and add to database
rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
