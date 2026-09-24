#!/bin/bash
set -e
# Variable declarations
name=xclip
depends=(autoconf bash coreutils git glibc libice libSM libX11 libXau libxcb libXdmcp libXext libxmu libXt make util-linux)
repo="astrand/xclip"
version=$(gh_com $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
# Fetch source
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
sudo autoreconf -fiv
sudo chown $USER -R .
cmi --prefix=/usr
sudo make install.man
cd ..
rm -rf $filename $direname
# Add to database
echo $version | sudo tee /var/lib/custom-packages/$name
