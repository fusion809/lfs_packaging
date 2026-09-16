#!/bin/bash
set -e
# Variable declarations
name=tesseract
version=$(gh_ver "tesseract-ocr/tesseract")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(acl bash brotli bzip2 coreutils curl cyrus-sasl gcc giflib glibc gzip icu leptonica libarchive libarchive libidn2 libjpeg-turbo libpng libpsl libtiff libunistring libwebp libxml2 lz4 make nghttp2 openjpeg openldap openssl pango tar wget xz zlib zstd)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/tesseract-ocr/tesseract/archive/$version.tar.gz -O $filename
fi
sudo rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
sudo ./autogen.sh
cmi --prefix=/usr
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
