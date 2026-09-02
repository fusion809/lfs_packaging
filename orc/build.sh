#!/bin/bash
set -e
# Variable declarations
name=orc
version=$(gfd_ver "gstreamer/orc")
direname="$name-$version"
filename="$direname.tar.xz"
depends=()
lfs_depends=(bash coreutils meson ninja pkgconf sed tar xz)
blfs_depends=(wget)
optional_depends=(libcacard) # Provides smartcard support
docs="CONTRIBUTING.md COPYING README RELEASE ROADMAP.md"
# check if libcacard is there
if pkg-config --exists libcacard ; then
  with_cacard="--enable-smartcard"
else
  with_cacard="--disable-smartcard"
fi
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c http://gstreamer.freedesktop.org/src/$name/$filename
fi
tar xvf $filename
# Compile and install
cd $direname
mni --prefix=/usr --buildtype=release .. &&
cd ..
sudo mkdir -p /usr/share/doc/$direname
for i in $docs
do
	sudo cp -a $i /usr/share/doc/$direname
done
sudo rm -f /usr/lib*/*.la
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
