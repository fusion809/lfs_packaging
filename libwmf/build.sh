#!/bin/bash
set -e
# Variable declarations
name=libwmf
version=$(gh_ver "caolanm/libwmf")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(autoconf bash brotli bzip2 coreutils expat fontconfig freetype gcc gdk-pixbuf glib2 glibc glycin gzip lcms2 libffi libjpeg-turbo libpng libseccomp libx11 libX11 libXau libxcb libXdmcp make pcre2 sed tar util-linux zlib zlib)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/caolanm/libwmf/archive/refs/tags/v${version}.tar.gz -O $filename
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
maki
# Cleanup and add to database
cd ..
rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
