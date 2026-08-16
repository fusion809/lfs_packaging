#!/bin/bash
set -e
# Variable declarations
name=portaudio
version=$(gh_ver "$name/$name")
filename="$name-v$version.tar.gz"
direname=$(echo "${filename/.tar.gz/}" | sed 's/v//g')
depends=(jack)
lfs_depends=(autoconf bash coreutils gcc glibc gzip make sed tar)
blfs_depends=(alsa-lib cmake opus wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/portaudio/portaudio/archive/v$version/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
configure_options=(
    --prefix=/usr
    --enable-cxx
  )
./configure "${configure_options[@]}"
make -j1
sudo make install
sudo mkdir /usr/share/doc/$direname/ -p
sudo install -Dm644 README.* /usr/share/doc/$direname/
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
