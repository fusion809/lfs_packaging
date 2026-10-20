#!/bin/bash
set -e
name=libxcrypt-compat
_name=libxcrypt
repo=besser82/$_name
homepage="https://github.com/besser82/libxcrypt/"
description="Modern library for one-way hashing of passwords."
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
rootdir=$PWD
unpk_enter "$filename" "$direname"
config_options=(--prefix=/usr \
    --disable-static \
    --enable-hashes=strong,glibc \
    --enable-obsolete-api=glibc \
    --disable-failure-tokens)
pkgdir=$rootdir/pkg
mkdir $pkgdir
./configure --prefix=/usr \
    --disable-static \
    --enable-hashes=strong,glibc \
    --enable-obsolete-api=glibc \
    --disable-failure-tokens
make -j$(nproc)
make DESTDIR="$pkgdir" install
rm -rf "${pkgdir}"/usr/{include,lib/{lib*.so,pkgconfig},share}
sudo rsync -aHAX "$pkgdir"/ /
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
