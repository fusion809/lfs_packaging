#!/bin/bash
set -e
name=xdg-utils
repo=xdg/$name
version=$(gfd_ver $repo)
filename="$name-v$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
        wget -c https://gitlab.freedesktop.org/$repo/-/archive/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
docbook_ver=$(pkgver docbook-xsl-nons)
sed -i -e "s|http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl|/usr/share/xml/docbook/xsl-stylesheets-nons-$docbook_ver/manpages/docbook.xsl|g" scripts/desc/*.xml
sed -i "s|\$(XMLTO) html-nochunks|\$(XMLTO) --skip-validation -x /usr/share/xml/docbook/xsl-stylesheets-nons-$docbook_ver/html/docbook.xsl html-nochunks|g" scripts/Makefile.in
sed -i "s|\$(XMLTO) txt|\$(XMLTO) --skip-validation -x /usr/share/xml/docbook/xsl-stylesheets-nons-$docbook_ver/html/docbook.xsl txt|g" scripts/Makefile.in
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
