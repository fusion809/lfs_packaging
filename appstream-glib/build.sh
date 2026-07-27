#!/bin/bash
set -e
# Variable declarations
name=appstream-glib
version=$(wget -cqO- https://people.freedesktop.org/~hughsient/appstream-glib/releases/ | grep -v "sha.*sum" | grep "appstream-glib-.*.tar.xz" | tail -n 1 | cut -d '"' -f 2 | sed 's/appstream-glib-//g' | sed 's/.tar.xz//g')
depends=()
blfs_depends=(curl gdk-pixbuf gtk3 json-glib libarchive libyaml gtk-doc)
pip_depends=()
direname="$name-$version"
filename="$direname.tar.xz"
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c http://people.freedesktop.org/~hughsient/appstream-glib/releases/$filename
fi
tar xvf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
# sed no longer needed for 1.1.4+ (xsl-ns -> xsl change was for older versions)
mkdir build
cd build
meson setup --prefix=/usr            \
            --buildtype=release      \
            -D rpm=false         \
            -D man=false        .. &&
ninja -j$(nproc)
sudo ninja install
# Cleanup and add to database
cd ..
rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
