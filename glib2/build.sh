#!/bin/bash
set -e
name=glib2
_name=glib
version=$(gn_ver $_name $name)
gobj_ver=$(gn_ver "gobject-introspection")
blfs_depends=(docutils libxslt)
lfs_depends=(bzip2 glibc libelf libffi util-linux xz zlib zstd)
depends=(pcre2)
filename="$_name-$version.tar.xz"
direname="$_name-$version"
gobj_filename="gobject-introspection-$gobj_ver.tar.xz"
gobj_direname="${gobj_filename/.tar.xz/}"

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
echo "Patching to remove warnings"
patch -Np1 -i ../glib-skip_warnings-1.patch
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
echo "$version" > /var/lib/custom-packages/$name

