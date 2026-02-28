#!/bin/bash
set -e
NAME=portaudio
VERSION=$(wget -cqO- https://github.com/portaudio/portaudio/releases | grep "releases/tag/v" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
filename="$NAME-v$VERSION.tar.gz"
direname="${filename/.tar.gz/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/portaudio/portaudio/archive/v$VERSION/$filename
fi
tar xf $filename
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
cd ..
rm -rf $filename $direname
