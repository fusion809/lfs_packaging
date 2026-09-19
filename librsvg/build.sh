#!/bin/bash
set -e
name=librsvg
repo=GNOME/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(cairo cargo-c gdk-pixbuf glib2 pango vala)
gn_download "$filename"
unpk_enter "$filename" "$direname"
sed -e "/OUTDIR/s|,| / 'librsvg-2.62.3', '--no-namespace-dir',|" \
    -e '/output/s|Rsvg-2.0|librsvg-2.62.3|'                      \
    -i doc/meson.build
mni --prefix=/usr --buildtype=release -Dpixbuf-loader=enabled
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
