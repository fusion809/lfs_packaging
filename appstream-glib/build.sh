#!/bin/bash
set -e
# Variable declarations
name=appstream-glib
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://people.freedesktop.org/~hughsient/appstream-glib/releases/ | grep -v "sha.*sum" | grep "appstream-glib-.*.tar.xz" | tail -n 1 | cut -d '"' -f 2 | sed 's/appstream-glib-//g' | sed 's/.tar.xz//g')
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return

	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(acl brotli bzip2 cairo curl cyrus-sasl expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 gtk3 gtk-doc harfbuzz json-glib lcms2 libarchive libarchive libepoxy libffi libidn2 libpng libpsl libseccomp libunistring libx11 libxau libxcb libxcomposite libxcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libXrandr libXrender libyaml lz4 nghttp2 openldap openssl pango pcre2 pixman util-linux wayland xz zlib zstd)
pip_depends=()
direname="$name-$version"
filename="$direname.tar.xz"
# Fetch and unpack source
download_src "http://people.freedesktop.org/~hughsient/appstream-glib/releases/$filename"
unpk_enter "$filename" "$direname"
# Compile and install
meson_options=(
	--prefix=/usr            \
    --buildtype=release      \
    -D rpm=false         \
    -D man=false
)
# sed no longer needed for 1.1.4+ (xsl-ns -> xsl change was for older versions)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
