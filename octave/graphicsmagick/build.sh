#!/bin/bash
set -e
NAME=graphicsmagick
VERSION=$(wget -cqO- https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/ | grep "/graphicsmagick/[0-9]" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6)
_archive="GraphicsMagick-$VERSION"
if ! [[ -f $_archive.tar.xz ]]; then
	wget -c https://downloads.sourceforge.net/project/$NAME/$NAME/$VERSION/$_archive.tar.xz
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
rm -rf $_archive*
