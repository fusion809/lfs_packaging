#!/bin/bash
set -e
# Variable declarations
name="leptonica"
version=$(gh_ver "DanBloomberg/leptonica")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(bash coreutils giflib glibc gzip libjpeg-turbo libpng libtiff libwebp make openjpeg sed tar wget xz zlib zstd)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/DanBloomberg/leptonica/archive/${version}.tar.gz -O $filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
sudo ./autogen.sh --prefix=/usr
sudo chown $USER -R .
cmi --prefix=/usr
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
