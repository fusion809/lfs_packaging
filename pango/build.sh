#!/bin/bash
set -e
name=pango
version=$(gn_ver pango)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
depends=(brotli bzip2 cairo expat fontconfig freetype fribidi glib2 glib2 glibc graphite2 harfbuzz libffi libpng libX11 libXau libxcb libXdmcp libXext libXft libXrender pcre2 pixman util-linux xorg-libs zlib)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://gitlab.gnome.org/GNOME/$name/-/archive/$version/$filename
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
echo $version | sudo tee /var/lib/custom-packages/$name
