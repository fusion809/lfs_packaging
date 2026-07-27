#!/bin/bash
set -e
source $HOME/lfs_packaging/shared-funcs.sh
name=libarchive
version=$(wget -cqO- https://github.com/libarchive/libarchive/releases | grep "/tag/" | head -n 1 | cut -d'"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
direname="$name-$version"
filename="$direname.tar.xz"
lfs_depends=(wget coreutils make gcc tar xz)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/libarchive/libarchive/releases/download/v$version/$filename
fi

rm -rf $direname
tar xf $filename
cd $direname
./configure --prefix=/usr --disable-static &&
make -j$(nproc)
sudo make install
sudo install -Dm755 ../unzip /usr/bin/
cd ..
rm -rf $direname $filename
echo "$version" > /var/lib/custom-packages/$name
