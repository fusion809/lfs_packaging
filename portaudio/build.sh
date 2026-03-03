#!/bin/bash
set -e
# Variable declarations
name=portaudio
version=$(wget -cqO- https://github.com/portaudio/portaudio/releases | grep "releases/tag/v" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
filename="$name-v$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(jack)
lfs_depends=(autoconf bash coreutils gcc glibc gzip make sed tar)
blfs_depends=(alsa-lib cmake wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/portaudio/portaudio/archive/v$version/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
cd bindings/cpp
autoreconf -fiv
cd ../..
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
autoreconf -fiv
configure_options=(
    --prefix=/usr
    --enable-cxx
  )
./configure "${configure_options[@]}"
make -j1
sudo make install
sudo install -Dmv644 README.* /usr/share/doc/$direname/
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/lfs-custom-packages/$name
