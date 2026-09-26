#!/bin/bash
set -e
# Variable declarations
name=tesseract
homepage="https://github.com/tesseract-ocr/tesseract"
description="An OCR program"
repo="tesseract-ocr/tesseract"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(acl bash brotli bzip2 coreutils curl cyrus-sasl gcc giflib glibc gzip icu leptonica libarchive libarchive libidn2 libjpeg-turbo libpng libpsl libtiff libunistring libwebp libxml2 lz4 make nghttp2 openjpeg openldap openssl pango tar wget xz zlib zstd)
# Fetch and unpack source
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
sudo ./autogen.sh
cmi --prefix=/usr
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
