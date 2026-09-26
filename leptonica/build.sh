#!/bin/bash
set -e
# Variable declarations
name="leptonica"
homepage="http://www.leptonica.com"
description="Software that is broadly useful for image processing and image analysis applications"
repo="DanBloomberg/leptonica"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(bash coreutils giflib glibc gzip libjpeg-turbo libpng libtiff libwebp make openjpeg sed tar wget xz zlib zstd)
# Fetch and unpack source
gha_download $repo $version $filename
unpk_enter "$filename" "$direname"
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
sudo ./autogen.sh --prefix=/usr
sudo chown $USER -R .
cmi --prefix=/usr
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
