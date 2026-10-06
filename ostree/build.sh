#!/bin/bash
set -e
# Variable declarations
name=ostree
homepage="https://ostreedev.github.io/ostree/"
description="Operating system and container binary deployment and upgrades."
repo=ostreedev/ostree
version=$(gh_ver $repo)
direname="lib${name}-$version"
filename="$direname.tar.xz"
depends=(acl avahi bash brotli bzip2 coreutils curl dbus e2fsprogs fuse gcab gcc glib glib2 glibc gpgme gtk-doc icu keyutils libarchive libassuan libffi libgpg-error libidn2 libpsl libsoup libunistring libxml2 libxslt lz4 make mitkrb nghttp2 openssl pcre2 python sed sqlite systemd tar util-linux wget which xz zlib zstd)
# Fetch and unpack source
ghr_download "$repo" "v${version}" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
configure_options=(
  --prefix=/usr \
  --libdir=/usr/lib \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --mandir=/usr/man \
  --enable-man=no \
  --docdir=/usr/share/doc/$direname
)
cmi "${configure_options[@]}"
sudo mkdir -p /usr/share/doc/$direname
sudo cp -a \
   COPYING README.md TODO \
   /usr/share/doc/$direname
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
