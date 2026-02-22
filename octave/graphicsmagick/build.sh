#!/bin/bash
pkgname=graphicsmagick
pkgver=1.3.46
_archive="GraphicsMagick-$pkgver"
wget -c https://downloads.sourceforge.net/project/$pkgname/$pkgname/$pkgver/$_archive.tar.xz
tar xf $_archive.tar.xz
cd $_archive
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

