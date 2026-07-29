#!/bin/bash
set -e
name=glib2
_name=glib
version=$(git ls-remote --tags --refs https://gitlab.gnome.org/GNOME/glib.git | grep "refs/tags/[0-9]" | tail -n 1 | cut -d '/' -f 3)
gobj_ver=$(git ls-remote --tags --refs https://gitlab.gnome.org/GNOME/gobject-introspection.git | grep "refs/tags/[0-9]" | tail -n 1 | cut -d '/' -f 3)
blfs_depends=(docutils libxslt)
filename="$_name-$version.tar.xz"
direname="$_name-$version"
gobj_filename="gobject-introspection-$gobj_ver.tar.xz"

if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/glib/$(echo $version | sed 's/.[0-9]$//g')/$filename
fi

if ! [[ -f $gobj_filename ]]; then
	wget -c https://download.gnome.org/sources/gobject-introspection/$(echo $gobj_ver | sed 's/.[0-9]$//g')/$gobj_filename
fi

if ! [[ -f glib-skip_warnings-1.patch ]]; then
	wget -c https://www.linuxfromscratch.org/patches/blfs/svn/glib-skip_warnings-1.patch
fi

rm -rf $direname
tar xf $filename
cd $direname
patch -Np1 -i ../glib-skip_warnings-1.patch
mkdir build &&
cd    build &&

meson setup ..                  \
      --prefix=/usr             \
      --buildtype=release       \
      -D introspection=disabled \
      -D glib_debug=disabled    \
      -D man-pages=disabled      \
      -D sysprof=disabled       &&
ninja -j$(nproc)
sudo ninja install
cd ../..
rm -rf $direname $filename $gobj_filename
echo "$version" > /var/lib/custom-packages/$name

