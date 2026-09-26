#!/bin/bash
set -e
# Variable declarations
name=appstream
homepage="https://distributions.freedesktop.org/wiki/AppStream"
description="Provides a standard for creating app stores across distributions"
version=$(gh_ver "ximion/appstream")
docs="AUTHORS CHANGELOG.md COPYING README"
depends=(brotli curl cyrus-sasl docbook-xsl-nons freetype2 gcc glib2 glibc itstool libffi libfyaml libidn2 libpsl libunistring libxml2 libxmlb libxslt llvm nghttp2 openldap openssl pcre2 qt6 systemd util-linux webkitgtk xz zlib zstd)
pip_depends=()
upName=AppStream;
direname="$upName-$version"
filename="$direname.tar.xz"
# Fetch and unpack source
download_src "https://www.freedesktop.org/software/appstream/releases/$filename"
unpk_enter "$filename" "$direname"
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
# sed no longer needed for 1.1.4+ (xsl-ns -> xsl change was for older versions)
# qt=true needed for plasma-workspace to build
meson_options=(
        --prefix=/usr            \
        --buildtype=release      \
        -D apidocs=false         \
	    -D qt=true               \
        -D bash-completion=false \
        -D stemming=false        \
        -D man=false
)
mni "${meson_options[@]}"
sudo rm -rf /usr/share/doc/appstream-$version
sudo mv -v /usr/share/doc/appstream{,-$version}
# Cleanup and add to database
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
