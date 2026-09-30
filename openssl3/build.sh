#!/bin/bash
set -e
name=openssl3
_name=openssl
repo=$_name/$_name
homepage="https://www.openssl.org"
description="OpenSSL 3.x series, required as a dependency of Julia."
version=$(gh_ver $repo "$name")
depends=(glibc)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$direname" "$filename"
unpk_enter "$filename" "$direname"
./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
make -j$(nproc)
mkdir pkg
make INSTALL_LIBS= MANSUFFIX=ssl install DESTDIR=pkg
sudo cp -v pkg/usr/lib/libssl.so.3 /usr/lib
sudo cp -v pkg/usr/lib/libcrypto.so.3 /usr/lib
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
