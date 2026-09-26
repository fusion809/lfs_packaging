#!/bin/bash
set -e
# Variable declarations
name=orc
description="Optimized Inner Loop Runtime Compiler"
repo="gstreamer/$name"
homepage="https://gstreamer.freedesktop.org/projects/orc.html"
version=$(gfd_ver "$repo")
direname="$name-$version"
filename="$direname.tar.xz"
depends=(bash coreutils meson ninja pkgconf sed tar wget xz)
optional_depends=(libcacard) # Provides smartcard support
docs="CONTRIBUTING.md COPYING README RELEASE ROADMAP.md"
# check if libcacard is there
if pkg-config --exists libcacard ; then
  with_cacard="--enable-smartcard"
else
  with_cacard="--disable-smartcard"
fi
# Fetch and unpack source
download_src "http://gstreamer.freedesktop.org/src/$name/$filename"
unpk_enter "$filename" "$direname"
# Compile and install
mni --prefix=/usr --buildtype=release .. &&
cd ../
sudo mkdir -p /usr/share/doc/$direname
for i in $docs
do
	sudo cp -a $i /usr/share/doc/$direname
done
sudo rm -f /usr/lib*/*.la
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
