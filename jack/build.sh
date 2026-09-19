#!/bin/bash
# Latest tagged version won't build
set -e
# Variable declarations
name=jack
reponame=jack2
repo=jackaudio/$reponame
version=$(gh_com $repo)
filename="$reponame-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(alsa-lib bash coreutils dbus dbus expat gcc glibc opus portaudio python systemd)
# Fetch and unpack source
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
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
rm -rf $filename $direname
# Add to database
echo $version | sudo tee /var/lib/custom-packages/$name
