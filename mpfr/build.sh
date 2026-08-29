#!/bin/bash
set -e
name=mpfr
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
lfs_depends=(gcc glibc make ncurses tar wget xz)
if ! [[ -f $filename ]]; then
    wget -c https://ftpmirror.gnu.org/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
./configure --prefix=/usr        \
            --enable-thread-safe \
            --disable-static     \
            --docdir=/usr/share/doc/$direname
make -j$(nproc)
make -j$(nproc) html

make check
sudo make install
sudo make install-html
cd ../..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
