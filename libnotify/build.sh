#!/bin/bash
set -e
# Variable declaration
name=libnotify
version=$(gn_ver libnotify)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
blfs_depends=(gdk-pixbuf glib2)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/libnotify/$(echo $version | sed 's/.[0-9]$//g')/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
sed -i -e "s|http://docbook.sourceforge.net/release/xsl-ns/current/manpages/docbook.xsl|/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2/manpages/docbook.xsl|g" meson.build
mkdir build
cd build
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
meson setup ..                     \
      --prefix=/usr                \
      --buildtype=release          \
      -D docbook_docs=disabled     \
      -D man=false                 \
      -D gtk_doc=false
ninja -j$(nproc)
sudo ninja install
sudo su -c "if [ -e /usr/share/doc/libnotify ]; then
  rm -rf /usr/share/doc/libnotify-$version
  mv -v  /usr/share/doc/libnotify{,-$version}
fi"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
