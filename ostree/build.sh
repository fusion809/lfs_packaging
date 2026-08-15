#!/bin/bash
set -e
# Variable declarations
name=ostree
version=$(gh_ver ostreedev/ostree)
direname="lib${name}-$version"
filename="$direname.tar.xz"
depends=(gcab)
lfs_depends=(bash coreutils glibc make python sed systemd tar util-linux xz zlib)
blfs_depends=(avahi curl e2fsprogs fuse glib gpgme gtk-doc libarchive libgpg-error libsoup libxslt openssl wget which)
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://github.com/ostreedev/ostree/releases/download/v${version}/$filename
fi
tar xvf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./configure \
  --prefix=/usr \
  --libdir=/usr/lib \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --mandir=/usr/man \
  --enable-man=no \
  --docdir=/usr/share/doc/$direname
make -j$(nproc)
sudo make install DESTDIR=/
sudo mkdir -p /usr/share/doc/$direname
sudo cp -a \
   COPYING README.md TODO \
   /usr/share/doc/$direname
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
