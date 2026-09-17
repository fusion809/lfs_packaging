#!/bin/bash
set -e
# Variable declarations
name=spice
version=$(spice_ver $name)
docs="AUTHORS CHANGELOG.md COPYING README"
depends=(bash bzip2 coreutils cyrus-sasl elfutils gcc glib glib2 glibc gst-plugins-base gstreamer libdrm libelf libffi libjpeg-turbo libunwind lz4 lz4 make meson openssl opus orc pcre2 pixman sasl sed spice-protocol systemd tar util-linux wget xz zlib zstd)
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
spice_download "$name" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
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
echo $version | sudo tee /var/lib/custom-packages/$name
