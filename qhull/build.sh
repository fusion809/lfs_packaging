#!/bin/bash
set -e
depends=()
lfs_depends=(bash coreutils glibc gzip sed tar)
blfs_depends=(cmake wget)
name=qhull
version=$(wget -cqO- http://www.qhull.org/download/ | grep ".tgz\"" | grep -v "alpha\|beta\|rc" | sed 's/.*Download: Qhull //g' | sed 's/ for Unix.*//g')
_version=$(wget -cqO- http://www.qhull.org/download/ | grep ".tgz\"" | grep -v "alpha\|beta\|rc" | cut -d '"' -f 2 | cut -d '/' -f 5 | cut -d '-' -f 4 | sed 's/.tgz//')
filename="$name-${version%.*}-src-$_version.tgz"
direname="$name-$version"
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
    -DCMAKE_POLICY_version_MINIMUM=3.5
cmake --build build
cmake --build build --target libqhull
sudo cmake --install build
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/lfs-custom-packages/$name