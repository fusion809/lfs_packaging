#!/bin/bash
set -e
name=librsvg
description="SVG rendering library."
homepage="https://wiki.gnome.org/Projects/LibRsvg"
repo=GNOME/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(brotli bzip2 cairo cargo-c dav1d expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 harfbuzz icu libffi libpng libseccomp libx11 libxau libxcb libxdmcp libxext libxml2 libxrender pango pcre2 pixman systemd util-linux vala zlib)
gn_download "$filename"
unpk_enter "$filename" "$direname"
sed -e "/OUTDIR/s|,| / 'librsvg-2.62.3', '--no-namespace-dir',|" \
    -e '/output/s|Rsvg-2.0|librsvg-2.62.3|'                      \
    -i doc/meson.build
mni --prefix=/usr --buildtype=release -Dpixbuf-loader=enabled
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
