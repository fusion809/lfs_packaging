#!/bin/bash
set -e
name=localsearch
homepage="https://gnome.pages.gitlab.gnome.org/localsearch/"
description="Filesystem indexer and metadata extractor."
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(acl brotli bzip2 cairo curl cyrus-sasl dav1d elfutils exempi exiv2 expat fdk-aac ffmpeg fontconfig freetype gcc gexiv2 giflib glib2 glibc gpgme gpgmepp graphite2 gst-plugins-base gstreamer harfbuzz icu inih jansson json-glib lame lcms2 libaom libarchive libassuan libdrm libelf libffi libgcrypt libgpg-error libgxps libidn2 libjpeg-turbo libogg libpng libpsl libseccomp libtiff libunistring libunwind libva libvorbis libvpx libwebp libx11 libxau libxcb libxdmcp libxext libxfixes libxml2 libxrender lz4 mpg123 nghttp2 nspr nss numactl openjpeg openldap openssl opus pcre2 pixman poppler sqlite svt-av1 systemd texlive tiff tinysparql totem-pl-parser upower util-linux x264 xdg-desktop-portal-kde xz zlib zstd)
blfs_depends=(gexiv2)
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
