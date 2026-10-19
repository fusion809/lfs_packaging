#!/bin/bash
set -e
name=libmspack
repo=kyz/$name
homepage="https://www.cabextract.org.uk/libmspack/"
description="Library for Microsoft compression formats."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cd $name
sudo autoreconf -fiv
sudo chown $USER -R .
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
make -j$(nproc)
sudo make install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
