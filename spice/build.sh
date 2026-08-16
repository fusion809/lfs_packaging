#!/bin/bash
set -e
# Variable declarations
name=spice
version=$(spice_ver $name)
docs="AUTHORS CHANGELOG.md COPYING README"
depends=(elfutils glib2 orc pcre2 spice-protocol)
lfs_depends=(bash bzip2 coreutils gcc glibc libelf libffi lz4 make meson openssl sed systemd tar util-linux xz zlib zstd)
blfs_depends=(cyrus-sasl glib gst-plugins-base gstreamer libdrm libjpeg-turbo libunwind lz4 opus pixman sasl wget)
pip_depends=(pyparsing)
# check if libcacard is there
if pkg-config --exists libcacard ; then
  with_cacard="--enable-smartcard"
else
  with_cacard="--disable-smartcard"
fi
direname="$name-$version"
filename="$direname.tar.bz2"
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://www.spice-space.org/download/releases/spice-server/$filename
fi
tar xvf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
configure_options=(
  --prefix=/usr \
  --libdir=/usr/lib \
  --docdir=/usr/share/doc/$direname \
  --disable-static \
  --enable-client \
  --disable-celt051 \
  $with_cacard
)
cmi "${configure_options[@]}"
sudo mkdir -p /usr/share/doc/$direname
sudo cp -a $docs /usr/share/doc/$direname
sudo rm -f /usr/lib*/*.la
# Cleanup and add to database
cd ..
rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
