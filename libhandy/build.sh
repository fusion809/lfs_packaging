#!/bin/bash
set -e
# Variable declaration
name=libhandy
version=$(gn_ver libhandy)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
blfs_depends=(at-spi2-core brotli cairo fontconfig freetype fribidi gdk-pixbuf glycin graphite2 gtk3 harfbuzz lcms2 libXau libXdmcp libepoxy libpng libseccomp libxcb libxkbcommon pixman vala webkitgtk)
lfs_depends=(bzip2 dbus expat gcc glibc libffi systemd util-linux zlib)
depends=(glib2 gtk3 libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXres pango pcre2 wayland)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/$name/$(echo $version | sed 's/.[0-9]$//g')/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
mkdir build
cd build
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
meson setup --prefix=/usr       \
            --buildtype=release \
	    ..
ninja -j$(nproc)
sudo ninja install
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
