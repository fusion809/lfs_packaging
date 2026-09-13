#!/bin/bash
set -e
name=glib-networking
version=$(gn_ver $name)
majVer=$(echo $version | sed -E "s/\.[0-9]+$//g")
depends=(glib2 glibc gmp gnutls libffi libidn2 libtasn1 libunistring nettle p11-kit pcre2 systemd util-linux zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.gnome.org/sources/glib-networking/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr        \
   --buildtype=release  \
   -D libproxy=disabled)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
