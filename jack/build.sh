#!/bin/bash
# Latest tagged version won't build
set -e
# Variable declarations
name=jack
reponame=jack2
repo=jackaudio/$reponame
version=$(git ls-remote https://github.com/$repo.git HEAD | awk '{print $1}')
filename="$reponame-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(portaudio)
lfs_depends=(bash coreutils dbus expat gcc glibc python systemd)
blfs_depends=(alsa-lib dbus opus)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/$version.tar.gz -O $filename
fi
# Compile and install
rm -rf $direname
tar xf $filename
cd $direname
sed -i -e "s|python$|python3|g" waf
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
echo $version > /var/lib/custom-packages/$name
