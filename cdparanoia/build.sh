#!/bin/bash
set -e
name=cdparanoia
repo=jwilk-mirrors/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-III-$version.src.tgz"
direname="${filename/.src.tgz/}"
echo "filename=$filename"
echo "direname=$direname"
if ! [[ -f $filename ]]; then
	wget -c https://downloads.xiph.org/releases/cdparanoia/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
gap_patches "$name" || echo "Apply patches failed... Continuing"
./configure --prefix=/usr --mandir=/usr/share/man
make -j1
sudo make install
sudo su -c "chmod -v 755 /usr/lib/libcdda_*.so.0.$version &&
rm -fv /usr/lib/libcdda_*.a"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
