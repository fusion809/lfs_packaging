#!/bin/bash
set -e
name=xdg-utils
homepage="https://gitlab.freedesktop.org/xdg/xdg-utils"
description="Command line tools that assist applications with a variety of desktop integration tasks"
repo=xdg/$name
version=$(gfd_ver $repo)
filename="$name-v$version.tar.gz"
direname="${filename/.tar.*/}"
gfd_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
docbook_ver=$(pkgver docbook-xsl-nons)
sed -i -e "s|http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl|/usr/share/xml/docbook/xsl-stylesheets-nons-$docbook_ver/manpages/docbook.xsl|g" scripts/desc/*.xml
sed -i "s|\$(XMLTO) html-nochunks|\$(XMLTO) --skip-validation -x /usr/share/xml/docbook/xsl-stylesheets-nons-$docbook_ver/html/docbook.xsl html-nochunks|g" scripts/Makefile.in
sed -i "s|\$(XMLTO) txt|\$(XMLTO) --skip-validation -x /usr/share/xml/docbook/xsl-stylesheets-nons-$docbook_ver/html/docbook.xsl txt|g" scripts/Makefile.in
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
