#!/bin/bash
# Originally a book package, but this script was written to fix a XSL stylesheet build failure
set -e
# Variable declarations
name=gtk3
version=$(gn_ver $name)
blfs_depends=(at-spi2-core avahi brotli cairo cups fontconfig freetype fribidi gdk-pixbuf glycin graphite2 harfbuzz lcms2 libXau libXdmcp libepoxy libeproxy libpng libseccomp libxcb libxkbcommon pango pixman)
depends=(colord glib2 libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXres pango pcre2 wayland)
lfs_depends=(bash bzip2 coreutils dbus expat gcc glibc libffi libxcrypt make meson openssl sed systemd tar util-linux zlib)
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
