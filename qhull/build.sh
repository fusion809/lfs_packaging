#!/bin/bash
set -e
depends=()
NAME=qhull
VERSION=$(wget -cqO- http://www.qhull.org/download/ | grep ".tgz\"" | grep -v "alpha\|beta\|rc" | sed 's/.*Download: Qhull //g' | sed 's/ for Unix.*//g')
_VERSION=$(wget -cqO- http://www.qhull.org/download/ | grep ".tgz\"" | grep -v "alpha\|beta\|rc" | cut -d '"' -f 2 | cut -d '/' -f 5 | cut -d '-' -f 4 | sed 's/.tgz//')
filename="$NAME-${VERSION%.*}-src-$_VERSION.tgz"
direname="$NAME-$VERSION"
if ! [[ -f $filename ]]; then
	wget -c http://www.qhull.org/download/$filename
fi
tar xf $filename
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
cmake -B build -S . \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_C_FLAGS="$CFLAGS -ffat-lto-objects" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS -ffat-lto-objects" \
    -DCMAKE_SKIP_RPATH=ON \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build build
cmake --build build --target libqhull
sudo cmake --install build
cd ..
sudo rm -rf $filename $direname
echo $VERSION > /var/lib/lfs-custom-packages/$NAME