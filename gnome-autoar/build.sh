#!/bin/bash
set -e
name=gnome-autoar
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(acl brotli bzip2 expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz icu libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXres libarchive libepoxy libffi libpng libxkbcommon libxml2 lz4 openssl pango pcre2 systemd util-linux wayland xz zlib zstd)
blfs_depends=(at-spi2-core cairo lcms2 libXau libXdmcp libseccomp libxcb pixman)
lfs_depends=(dbus)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr --buildtype=release -D vapi=true        \
            -D tests=true)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
