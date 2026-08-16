#!/bin/bash
set -e
# Variable declarations
name=gnuplot
version=$(sf_ver "gnuplot/gnuplot-main")
direname="$name-$version"
filename="$direname.tar.gz"
depends=(glib2 libX11 libXext libXrender pango pcre2)
lfs_depends=(bash bzip2 coreutils expat gcc glibc gzip libffi make ncurses readline tar util-linux zlib)
blfs_depends=(brotli cairo fontconfig freetype fribidi gd glib graphite2 gtk3 harfbuzz libXau libXdmcp libpng libwebp libx11 libxcb lua pango pixman qt6)
# libcaca, libcerf  and wxwidgets are listed for Arch, but seems to run for my uses without them
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://sourceforge.net/projects/gnuplot/files/gnuplot/$version/$filename
fi
tar -zxvf $filename
# Compile and install
cd $direname
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
echo $version > /var/lib/custom-packages/$name
