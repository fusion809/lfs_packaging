#!/bin/bash
# Latest tagged version won't build
set -e
# Variable declarations
name=jack
direname=jack2
depends=()
lfs_depends=(bash coreutils expat python systemd)
blfs_depends=(alsa-lib dbus opus)
# Fetch and unpack source
if ! [[ -d $direname ]]; then
	git clone https://github.com/jackaudio/jack2
fi
# Compile and install
cd $direname
version=$(git log | head -n 1 | cut -d ' ' -f 2)
git pull origin master
sed -i -e "s|python|python3|g" waf
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./waf configure \
  --prefix=/usr \
  --libdir=/usr/lib \
  --mandir=/usr/man/man1 \
  --htmldir=/usr/doc/$name-$version/html \
  --classic \
  --dbus \
  --alsa
./waf build
sudo ./waf install
cd ..
# Add to database
echo $version > /var/lib/lfs-custom-packages/$name
