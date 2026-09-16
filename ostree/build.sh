#!/bin/bash
set -e
# Variable declarations
name=ostree
version=$(gh_ver ostreedev/ostree)
direname="lib${name}-$version"
filename="$direname.tar.xz"
depends=(avahi bash coreutils curl e2fsprogs fuse gcab glib glibc gpgme gtk-doc libarchive libgpg-error libsoup libxslt make openssl python sed systemd tar util-linux wget which xz zlib)
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/ostreedev/ostree/releases/download/v${version}/$filename
fi
tar xf $filename
# Compile and install
cd $direname
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
