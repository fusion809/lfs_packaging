#!/bin/bash
set -e
# Variable declaration
name=udisks
version="$(wget -cqO- https://github.com/storaged-project/udisks/releases | grep "/tag/udisks-" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | cut -d '-' -f 2)"
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
blfs_depends=(libatasmart libblockdev libgudev polkit elogind glib2)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://github.com/storaged-project/udisks/releases/download/$direname/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
./configure --prefix=/usr        \
            --sysconfdir=/etc    \
            --localstatedir=/var \
            --disable-static     \
            --enable-available-modules &&
sed -i -e "s|http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl|/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2/manpages/docbook.xsl|g" doc/man/Makefile
	    make -j$(nproc)

sudo make install
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
