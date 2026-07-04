#!/bin/bash
set -e
# Variable declarations
name=imagemagick
version=$(wget -cqO- https://github.com/ImageMagick/ImageMagick/releases | grep "\.tar\.gz" | cut -d '"' -f 2 | cut -d '/' -f 7 | sed 's/.tar.gz//g')
lfs_depends=(bzip2 fftw fontconfig freetype glibc gcc xz libpng zlib)
blfs_depends=(xorg-lib)
direname="ImageMagick-$version"
filename="$version.tar.gz"
# Fetch and unpack source
sudo rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://github.com/ImageMagick/ImageMagick/archive/refs/tags/$filename
fi
tar xvf $filename
# Compile and install
cd $direname
./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --enable-hdri     \
            --with-modules    \
            --with-perl       \
            --disable-static  &&
make -j$(nproc)
sudo make install DESTDIR=/
sudo make DOCUMENTATION_PATH=/usr/share/doc/imagemagick-${version/-.*/} install
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
