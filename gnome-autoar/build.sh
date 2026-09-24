#!/bin/bash
set -e
name=gnome-autoar
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(acl at-spi2-core brotli bzip2 cairo dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz icu lcms2 libarchive libepoxy libffi libpng libseccomp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender libxres lz4 openssl pango pcre2 pixman systemd util-linux wayland xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(
    --prefix=/usr \
    --buildtype=release \
    -D vapi=true        \
    -D tests=true)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
