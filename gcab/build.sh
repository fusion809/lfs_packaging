#!/bin/bash
set -e
# Variable declarations
name=gcab
homepage="https://wiki.gnome.org/msitools"
description="A GObject library to create cabinet files"
version=$(gn_ver $name)
direname="$name-$version"
filename="$direname.tar.xz"
depends=(bash coreutils gcc glib glib2 glibc gtk-doc libffi meson ninja pcre2 sed tar util-linux vala xz zlib)
# Fetch and unpack source
gn_download "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
meson_options=(
  --buildtype=release \
  --infodir=/usr/info \
  --libdir=/usr/lib \
  --localstatedir=/var \
  --mandir=/usr/man \
  --prefix=/usr \
  --sysconfdir=/etc \
  -Dstrip=true
)
mni "${meson_options[@]}"
cd ..
sudo rm -f /usr/lib*/*.la
sudo mkdir -p /usr/share/doc/$direname
sudo cp -a \
   COPYING NEWS README.md RELEASE \
   /usr/share/doc/$direname
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
