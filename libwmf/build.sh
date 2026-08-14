#!/bin/bash
set -e
# Variable declarations
name=libwmf
version=$(gh_ver "caolanm/libwmf")
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
sudo autoreconf -fi
sudo chmod 777 -R *
./configure --prefix=/usr \
	--with-gsfontmap=/usr/share/ghostscript/Resource/Init/Fontmap.GS
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
make -j$(nproc)
sudo make install
# Cleanup and add to database
cd ..
rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
