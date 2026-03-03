#!/bin/bash
NAME=libwmf
VERSION=$(wget -cqO- https://github.com/caolanm/libwmf/releases | grep "/tag/v" | grep -v "alpha\|beta\|[0-9]rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
depends=()
lfs_depends=(autoconf bash coreutils glibc gzip make sed tar)
blfs_depends=(gdk-pixbuf libjpeg-turbo libpng libx11 zlib)
filename="$NAME-$VERSION.tar.gz"
direname="${filename/.tar.gz/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/caolanm/libwmf/archive/refs/tags/v${VERSION}.tar.gz -O $filename
fi
tar xf $filename
cd $direname
autoreconf -fi
./configure --prefix=/usr \
	--with-gsfontmap=/usr/share/ghostscript/Resource/Init/Fontmap.GS
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
make -j$(nproc)
sudo make install
