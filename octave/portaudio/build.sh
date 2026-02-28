#!/bin/bash
set -e
NAME=portaudio
VERSION=$(wget -cqO- https://github.com/portaudio/portaudio/releases | grep "releases/tag/v" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
filename="$NAME-v$VERSION.tar.gz"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/portaudio/portaudio/archive/v$VERSION/$filename
fi
tar xf $filename
cd ${filename/.tar.gz/}
cd bindings/cpp
autoreconf -fiv
cd ../..
autoreconf -fiv
configure_options=(
    --prefix=/usr
    --enable-cxx
  )
./configure "${configure_options[@]}"
make -j1
sudo make install
sudo install -Dmv644 README.* /usr/share/doc/$NAME-$VERSION/
cd ..
rm -rf $filename ${filename/.tar.gz/}
