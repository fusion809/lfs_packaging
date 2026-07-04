#!/bin/bash
set -e
# Variable declarations
name=gtk3
version=$(wget -cqO- https://gitlab.gnome.org/GNOME/gtk/-/tags | grep "\-3\." | head -n 1 | cut -d '/' -f 6)
blfs_depends=(at-spi2-core gdk-pixbuf libeproxy pango)
lfs_depends=(bash coreutils make meson sed tar)
direname="gtk-$version"
filename="$direname.tar.bz2"
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.gnome.org/GNOME/gtk/-/archive/$version/$filename
fi
tar xvf $filename
# Compile and install
cd $direname
mkdir build &&
cd    build &&

meson setup ..            \
      --prefix=/usr       \
      --buildtype=release \
      -D man=true         \
      -D broadway_backend=true &&
docbookver=$(cat /var/lib/book-packages/docbook-xsl-nons | head -n 1)
sed -i -e "s|http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl|/usr/share/xml/docbook/xsl-stylesheets-nons-$docbookver/manpages/docbook.xsl|g" build.ninja ../docs/reference/gtk/meson.build 
ninja -j$(nproc)
sudo ninja install
cd ..
rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
