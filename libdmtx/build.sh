#!/bin/bash
# Included because it's required by prison-6.24.0 of kframeworks
set -e
name=libdmtx
version=$(gh_ver "dmtx/libdmtx")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=()
lfs_depends=(glibc)
blfs_depends=()

if ! [[ -f $filename ]]; then
	wget -c https://github.com/dmtx/libdmtx/archive/refs/tags/v${version}.tar.gz -O $filename
fi

tar xf $filename
cd $direname
autoreconf -vi
cmi --prefix=/usr
cd ..
sudo rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
