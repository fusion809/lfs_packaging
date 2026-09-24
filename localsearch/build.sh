#!/bin/bash
set -e
name=localsearch
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(acl brotli bzip2 cairo curl cyrus-sasl elfutils exempi expat fontconfig freetype gcc gexiv2 giflib glib2 glibc gpgme gpgmepp gst-plugins-base gstreamer icu inih jansson json-glib lcms2 libarchive libassuan libelf libffi libgcrypt libgpg-error libgxps libidn2 libjpeg-turbo libpng libpsl libseccomp libtiff libunistring libunwind libwebp libX11 libxau libxcb libXdmcp libXext libxml2 libXrender lz4 nghttp2 nspr nss openjpeg openldap openssl pcre2 pixman poppler sqlite systemd tinysparql totem-pl-parser upower util-linux xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
# Requires some security options kernel options
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(--prefix=/usr --buildtype=release -D man=false              \
            -D functional_tests=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
