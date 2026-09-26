#!/bin/bash
set -e
# Variable declarations
name=ostree
homepage="https://ostreedev.github.io/ostree/"
description="Operating system and container binary deployment and upgrades"
repo=ostreedev/ostree
version=$(gh_ver $repo)
direname="lib${name}-$version"
filename="$direname.tar.xz"
depends=(avahi bash coreutils curl e2fsprogs fuse gcab glib glibc gpgme gtk-doc libarchive libgpg-error libsoup libxslt make openssl python sed systemd tar util-linux wget which xz zlib)
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
