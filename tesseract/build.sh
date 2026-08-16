#!/bin/bash
set -e
# Variable declarations
name=tesseract
version=$(gh_ver "tesseract-ocr/tesseract")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(leptonica libarchive openldap)
lfs_depends=(acl bash bzip2 coreutils gcc glibc gzip lz4 make openssl tar xz zlib zstd)
blfs_depends=(brotli curl cyrus-sasl giflib icu libarchive libidn2 libjpeg-turbo libpng libpsl libtiff libunistring libwebp libxml2 nghttp2 openjpeg pango wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/tesseract-ocr/tesseract/archive/$version.tar.gz -O $filename
fi
sudo rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
sudo ./autogen.sh
./configure --prefix=/usr
make -j$(nproc)
sudo make install
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
