#!/bin/bash
set -e
# Variable declarations
name=xclip
depends=()
lfs_depends=(autoconf bash coreutils glibc make util-linux)
blfs_depends=(git libXau libXdmcp libxcb libxmu libICE libSM libX11 libXext libXt)
repo="astrand/xclip"
version=$(gh_com $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
# Fetch source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/$version.tar.gz -O $filename
fi
rm -rf $direname
tar xf $filename
cd $direname
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
autoreconf
cmi "--prefix=/usr"
sudo make install.man
cd ..
rm -rf $filename $direname
# Add to database
echo $version > /var/lib/custom-packages/$name
