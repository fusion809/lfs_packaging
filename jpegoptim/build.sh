#!/bin/bash
set -e
name=jpegoptim
source ~/lfs_packaging/shared-funcs.sh
version=$(github_ver tjko/$name | sed 's/v//g')
filename="$name-$version.tar.gz"
direname="$name-$version"
blfs_depends=(libjpeg)

if ! [[ -f "$filename" ]]; then
	wget -c https://github.com/tjko/jpegoptim/releases/download/v$version/$filename
fi

rm -rf $direname
tar xf $filename
cd $direname
./configure --prefix=/usr
make -j$(nproc)
make strip -j$(nproc)
sudo make install
cd ..
rm -rf $direname
echo "$version" > /var/lib/custom-packages/$name
