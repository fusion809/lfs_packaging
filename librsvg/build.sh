#!/bin/bash
set -e
name=librsvg
repo=GNOME/$name
version=$(gh_ver $repo)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(cairo cargo-c pango gdk-pixbuf glib2 vala)
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/librsvg/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -e "/OUTDIR/s|,| / 'librsvg-2.62.3', '--no-namespace-dir',|" \
    -e '/output/s|Rsvg-2.0|librsvg-2.62.3|'                      \
    -i doc/meson.build
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
