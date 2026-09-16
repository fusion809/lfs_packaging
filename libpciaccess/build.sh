#!/bin/bash
set -e
# Variable declarations
name=libpciaccess
version=$(xfd_ver $name)
filename="$name-$version.tar.xz"
direname=${filename/.tar.xz/}
depends=(bash coreutils glibc make meson ninja sed tar util-macros wget xz zlib)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://xorg.freedesktop.org/releases/individual/lib/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
meson_options=(
	--prefix=/usr       \
	--libdir=/usr/lib   \
    --buildtype=release
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
