#!/bin/bash
set -e
name=glib-networking
homepage="https://gitlab.gnome.org/GNOME/glib-networking"
description="Network extensions for GLib"
version=$(gn_ver $name)
depends=(glib2 glibc gmp gnutls libffi libidn2 libtasn1 libunistring nettle p11-kit pcre2 systemd util-linux zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(--prefix=/usr        \
   --buildtype=release  \
   -D libproxy=disabled)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
