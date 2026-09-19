#!/bin/bash
set -e
name=libxslt
version=$(gn_ver $name)
majVer=$(echo $version | sed -E 's/.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(docbook-xml docbook-xsl-nons libxml2)
gn_download "$filename"
unpk_enter "$filename" "$direname"
configure_options=(--prefix=/usr    \
            --disable-static \
            --without-python \
	    --docdir=/usr/share/doc/$direname)
cmi "${configure_options[@]}"
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
