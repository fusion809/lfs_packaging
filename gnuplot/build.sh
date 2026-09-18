#!/bin/bash
set -e
# Variable declarations
name=gnuplot
version=$(sf_ver "gnuplot/gnuplot-main")
direname="$name-$version"
filename="$direname.tar.gz"
depends=(bash brotli bzip2 cairo coreutils expat fontconfig freetype fribidi gcc gd glib glib2 glibc graphite2 gtk3 gzip harfbuzz libffi libpng libwebp libx11 libX11 libXau libxcb libXdmcp libXext libXrender lua make ncurses pango pango pcre2 pixman qt6 readline tar util-linux zlib)
# libcaca, libcerf  and wxwidgets are listed for Arch, but seems to run for my uses without them
# Fetch and unpack source
sf_download "$name" "$version" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./configure --prefix=/usr \
            --sysconfdir=/etc \
            --mandir=/usr/man \
            --infodir=/usr/info \
            --datadir=/usr/share/gnuplot \
            --with-caca \
            --with-readline=gnu 

make -j$(nproc) pkglibexecdir=/usr/bin || exit 1
sudo make DESTDIR=/ install || exit 2
docdir="/usr/share/doc/$name-$version"
sudo mkdir -p $docdir
sudo cp Copyright RELEASE_NOTES NEWS $docdir 
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
