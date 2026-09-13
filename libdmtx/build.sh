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
	wget -c --progress=bar:force https://github.com/dmtx/libdmtx/archive/refs/tags/v${version}.tar.gz -O $filename
fi

tar xf $filename
cd $direname
sudo autoreconf -vi
sudo chown $USER -R .
cmi --prefix=/usr
cd ..
sudo rm -rf $filename $direname
echo "$version" sudo tee /var/lib/custom-packages/$name
