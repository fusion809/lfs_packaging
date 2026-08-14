#!/bin/bash
set -e
name=glib2
_name=glib
version=$(gn_ver $_name $name)

get_gobj() {
      local up_ver=$(wget -cqO- https://gitlab.gnome.org/GNOME/gobject-introspection/-/tags | grep "/tags/[0-9]" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 2| cut -d '/' -f 6)
      if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$up_ver"
		return 0
	fi

      local git_ver=$(git ls-remote --tags --refs https://gitlab.gnome.org/GNOME/gobject-introspection.git | grep "refs/tags/[0-9]" | tail -n 1 | cut -d '/' -f 3)
	if echo "$git_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$git_ver"
		return 0
	fi

	local arch_ver=$(aver gobject-introspection)
	if echo "$arch_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$arch_ver"
		return 0
	fi
}

gobj_ver=$(get_gobj)
blfs_depends=(docutils libxslt)
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
echo "Initial build of GObject-Introspection..."
tar xf ../../$gobj_filename &&

meson setup $gobj_direname gi-build \
            --prefix=/usr --buildtype=release     &&
ninja -C gi-build -j$(nproc)
sudo ninja -C gi-build install
echo "Now rebuilding GLIB2 with introspection enabled..."
meson configure -D introspection=enabled &&
ninja -j$(nproc)
sudo ninja install
echo "Build finished, cleaning up..."
cd ../..
rm -rf $direname $filename $gobj_filename
echo "$version" > /var/lib/custom-packages/$name

