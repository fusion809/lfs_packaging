#!/bin/bash
set -e
name=xmlto
version=$(wget -cqO- https://pagure.io/xmlto/releases | grep "/xmlto/archive/.*tar.gz" | cut -d '"' -f 2 | cut -d '/' -f 4)
direname="$name-$version"
filename="$direname.tar.gz"
blfs_depends=(docbook-xml docbook-xsl-nons libxslt)
xslver=$(cat /var/lib/book-packages/docbook-xsl-nons | head -n 1)

if ! [[ -f $filename ]]; then
	wget -c https://pagure.io/xmlto/archive/$version/$filename
fi

tar xf "$filename"
cd "$direname"
sed -i -e "s|http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl|/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2/manpages/docbook.xsl|g" format/docbook/man
autoreconf -fiv                                  &&
LINKS="/usr/bin/links" ./configure --prefix=/usr &&

make -j$(nproc)
sudo make install
cd ..
rm -rf "$direname"
echo "$version" > /var/lib/custom-packages/$name
