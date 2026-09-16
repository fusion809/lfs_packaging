#!/bin/bash
set -e
# Variable declaration
name=libnotify
version=$(gn_ver libnotify)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
depends=(brotli bzip2 expat fontconfig freetype gcc gdk-pixbuf glib2 glib2 glibc glycin lcms2 libffi libpng libseccomp pcre2 util-linux zlib)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.gnome.org/sources/libnotify/$(echo $version | sed 's/.[0-9]$//g')/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
docbook_ver=$(pkgver docbook-xsl-nons)
sed -i -e "s|http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl|/usr/share/xml/docbook/xsl-stylesheets-nons-$docbook_ver/manpages/docbook.xsl|g" meson.build
meson_options=(
  --prefix=/usr                \
  --buildtype=release          \
  -D docbook_docs=disabled     \
  -D man=false                 \
  -D gtk_doc=false
)
mni "${meson_options[@]}"
sudo su -c "if [ -e /usr/share/doc/libnotify ]; then
  rm -rf /usr/share/doc/libnotify-$version
  mv -v  /usr/share/doc/libnotify{,-$version}
fi"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
