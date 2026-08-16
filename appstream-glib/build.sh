#!/bin/bash
set -e
# Variable declarations
name=appstream-glib
get_version() {
	local up_ver=$(wget -T 5 -cqO- https://people.freedesktop.org/~hughsient/appstream-glib/releases/ | grep -v "sha.*sum" | grep "appstream-glib-.*.tar.xz" | tail -n 1 | cut -d '"' -f 2 | sed 's/appstream-glib-//g' | sed 's/.tar.xz//g')
	ver_check "$up_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" && return
}
version=$(get_version)
depends=(glib2 gtk3 libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libarchive openldap pango pcre2 wayland)
lfs_depends=(acl bzip2 expat gcc glibc libffi lz4 openssl util-linux xz zlib zstd)
blfs_depends=(brotli cairo curl cyrus-sasl fontconfig freetype fribidi gdk-pixbuf glycin graphite2 gtk-doc gtk3 harfbuzz json-glib lcms2 libXau libXdmcp libarchive libepoxy libidn2 libpng libpsl libseccomp libunistring libxcb libxkbcommon libxml2 libyaml nghttp2 pixman)
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
