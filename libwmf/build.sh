#!/bin/bash
set -e
# Variable declarations
name=libwmf
version=$(wget -cqO- https://github.com/caolanm/libwmf/releases | grep "/tag/v" | grep -v "alpha\|beta\|[0-9]rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=()
lfs_depends=(autoconf bash coreutils glibc gzip make sed tar)
blfs_depends=(gdk-pixbuf libjpeg-turbo libpng libx11 zlib)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/caolanm/libwmf/archive/refs/tags/v${version}.tar.gz -O $filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
autoreconf -fi
./configure --prefix=/usr \
	--with-gsfontmap=/usr/share/ghostscript/Resource/Init/Fontmap.GS
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
make -j$(nproc)
sudo make install
# Cleanup and add to database
cd ..
rm -rf $direname $filename
echo $version > /var/lib/lfs-custom-packages/$name