#!/bin/bash
set -e
name=libdaemon
version=$(gh_ver Distrotech/libdaemon)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://0pointer.de/lennart/projects/libdaemon/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
./configure --prefix=/usr --disable-static
make -j$(nproc)
sudo make docdir=/usr/share/doc/$direname install
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
