#!/bin/bash
set -e
depends=()
name=graphicsmagick
version=$(wget -cqO- https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/ | grep "/graphicsmagick/[0-9]" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6)
depends=()
lfs_depends=(bash bzip2 coreutils libtool perl tar xz)
blfs_depends=(freetype jasper libheif libjxl libpng libsm # Xorg lib
libtiff libwebp libxext # Xorg lib
libxml2
libwmf
littlecms wget)
_archive="GraphicsMagick-$version"
if ! [[ -f $_archive.tar.xz ]]; then
	wget -c https://downloads.sourceforge.net/project/$name/$name/$version/$_archive.tar.xz
fi
tar xf $_archive.tar.xz
cd $_archive
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
sed -e "s:freetype_config='':freetype_config='/usr/bin/pkg-config freetype2':g" -i configure
./configure \
	--prefix=/usr \
	--enable-shared \
	--with-modules \
	--with-perl \
	--with-quantum-depth=16 \
	--with-magick_plus_plus \
	--with-threads
make -j$(nproc)
sudo make install
cd PerlMagick
sed -i -e "s:'LDDLFLAGS'  => \"\(.*\)\":'LDDLFLAGS'  => \"-L${pkgdir}/usr/lib \1\":" Makefile.PL
perl Makefile.PL INSTALLDIRS=vendor PREFIX=/usr DESTDIR="${pkgdir}"
sed -i -e "s/LDLOADLIBS =/LDLOADLIBS = -lGraphicsMagick/" Makefile
make -j$(nproc)
sudo make install
cd ..
sudo rm -rf $_archive*
echo $version > /var/lib/lfs-custom-packages/$name
