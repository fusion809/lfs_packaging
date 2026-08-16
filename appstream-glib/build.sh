#!/bin/bash
set -e
# Variable declarations
name=appstream-glib
get_version() {
	local up_ver=$(wget -T 5 -cqO- https://people.freedesktop.org/~hughsient/appstream-glib/releases/ | grep -v "sha.*sum" | grep "appstream-glib-.*.tar.xz" | tail -n 1 | cut -d '"' -f 2 | sed 's/appstream-glib-//g' | sed 's/.tar.xz//g')
	if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$up_ver"
		return 0
	fi

	local arch_ver=$(aver $name)
	if echo "$arch_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$arch_ver"
		return 0
	fi
}
version=$(get_version)
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
