#!/bin/bash
set -e
name=libxslt
version=$(gn_ver $name)
majVer=$(echo $version | sed -E 's/.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(libxml2 docbook-xml docbook-xsl-nons)
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/libxslt/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
configure_options=(--prefix=/usr    \
            --disable-static \
            --without-python \
	    --docdir=/usr/share/doc/$direname)
cmi "${configure_options[@]}"
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
