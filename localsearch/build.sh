#!/bin/bash
set -e
name=localsearch
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(acl brotli bzip2 curl cyrus-sasl elfutils exempi expat fontconfig freetype gcc giflib glib2 glibc gpgme gpgmepp gst-plugins-base gstreamer icu inih jansson json-glib libX11 libXext libXrender libarchive libassuan libffi libgcrypt libgpg-error libidn2 libpng libpsl libunistring libxml2 lz4 nghttp2 nspr nss openldap openssl pcre2 sqlite systemd tinysparql util-linux xz zlib zstd)
blfs_depends=(cairo gexiv2 lcms2 libXau libXdmcp libgxps libjpeg-turbo libseccomp libtiff libunwind libwebp libxcb openjpeg pixman poppler totem-pl-parser upower)
lfs_depends=(libelf)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
# Requires some security options kernel options
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr --buildtype=release -D man=false              \
            -D functional_tests=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
