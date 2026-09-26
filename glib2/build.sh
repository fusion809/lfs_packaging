#!/bin/bash
set -e
name=glib2
homepage="https://gitlab.gnome.org/GNOME/glib"
description="Low level core library"
_name=glib
version=$(gn_ver $_name $name)
gobj_ver=$(gn_ver "gobject-introspection")
depends=(bzip2 docutils glibc libelf libffi libxslt pcre2 util-linux xz zlib zstd)
filename="$_name-$version.tar.xz"
direname="$_name-$version"
gobj_filename="gobject-introspection-$gobj_ver.tar.xz"
gobj_direname="${gobj_filename/.tar.xz/}"
gn_download "$filename"
gn_download "$gobj_filename"
unpk_enter "$filename" "$direname"
gap_patches "$name"
echo "Initial build of GLIB2..."
meson_options=(
      --prefix=/usr             \
      --buildtype=release       \
      -D introspection=disabled \
      -D glib_debug=disabled    \
      -D man-pages=disabled      \
      -D sysprof=disabled
)
mni "${meson_options[@]}"
echo "Initial build of GObject-Introspection..."
tar xf ../../$gobj_filename
mni --prefix=/usr --buildtype=release $gobj_direname
echo "Now rebuilding GLIB2 with introspection enabled..."
mni -D introspection=enabled
echo "Build finished, cleaning up..."
cd ../..
rm -rf $direname $filename $gobj_filename
echo "$version" | sudo tee /var/lib/custom-packages/$name

