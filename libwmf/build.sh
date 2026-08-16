#!/bin/bash
set -e
# Variable declarations
name=libwmf
version=$(gh_ver "caolanm/libwmf")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(glib2 libX11 pcre2)
lfs_depends=(autoconf bash bzip2 coreutils expat gcc glibc gzip libffi make sed tar util-linux zlib)
blfs_depends=(brotli fontconfig freetype gdk-pixbuf glycin lcms2 libXau libXdmcp libjpeg-turbo libpng libseccomp libx11 libxcb zlib)
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
