#!/bin/bash
set -e
# Variable declarations
name=xclip
depends=(autoconf bash coreutils git glibc libICE libSM libX11 libXau libxcb libXdmcp libXext libxmu libXt make util-linux)
repo="astrand/xclip"
version=$(gh_com $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
# Fetch source
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/archive/$version.tar.gz -O $filename
fi
rm -rf $direname
tar xf $filename
cd $direname
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
