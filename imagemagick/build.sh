#!/bin/bash
# Originally a book package; script written to overcome download failure
set -e
# Variable declarations
name=imagemagick
version=$(gh_ver "ImageMagick/ImageMagick")
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
sudo rm -f /usr/lib/libMagickCore-7.Q16HDRI.so* /usr/lib/libMagickWand-7.Q16HDRI.so* /usr/lib/libMagick++-7.Q16HDRI.so*
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
