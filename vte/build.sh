#!/bin/bash
set -e
name=vte
version=$(gn_ver vte)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(fast_float fmt glib2 gnutls gtk3 gtk4 icu libxml2 simdutf vala)
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://gitlab.gnome.org/GNOME/vte/-/archive/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
mni --prefix=/usr --buildtype=release
sudo rm -v /etc/profile.d/vte.*
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
