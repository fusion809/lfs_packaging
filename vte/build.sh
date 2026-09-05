#!/bin/bash
set -e
name=vte
version=$(gn_ver vte)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(libxml2 fast_float fmt icu gnutls glib2 gtk3 gtk4 simdutf vala)
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.gnome.org/GNOME/vte/-/archive/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
mni --prefix=/usr --buildtype=release
sudo rm -v /etc/profile.d/vte.*
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
