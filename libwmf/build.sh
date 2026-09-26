#!/bin/bash
set -e
# Variable declarations
name=libwmf
homepage="https://github.com/caolanm/libwmf"
description="A library for reading vector images in Microsoft's native Windows Metafile Format (WMF)"
repo=caolanm/libwmf
version=$(gh_ver "$repo")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(autoconf bash brotli bzip2 coreutils expat fontconfig freetype gcc gdk-pixbuf glib2 glibc glycin gzip lcms2 libffi libjpeg-turbo libpng libseccomp libx11 libx11 libxau libxcb libxdmcp make pcre2 sed tar util-linux zlib zlib)
# Fetch and unpack source
gha_download "$repo" "v${version}" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
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
