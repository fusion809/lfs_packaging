#!/bin/bash
set -e
name=pango
version=$(gn_ver pango)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
blfs_depends=(brotli cairo fontconfig freetype fribidi glib2 graphite2 harfbuzz libXau libXdmcp libpng libxcb pixman)
lfs_depends=(bzip2 expat glibc libffi util-linux zlib)
depends=(glib2 libX11 libXext libXft libXrender pcre2 xorg-libs)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.gnome.org/GNOME/$name/-/archive/$version/$filename
fi
rm -rf "$direname"
tar xf $filename
# Compile and install
cd "$direname"
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
meson_options=(
    --prefix=/usr            \
    --buildtype=release      \
    --wrap-mode=nofallback   \
    -D introspection=enabled
    )
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
