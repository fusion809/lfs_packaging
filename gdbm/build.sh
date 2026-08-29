#!/bin/bash
set -e
name=gdbm
version=$(gnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
lfs_depends=(gcc glibc make ncurses readline tar wget gzip)
if ! [[ -f $filename ]]; then
    wget -c https://ftpmirror.gnu.org/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --disable-static --enable-libgdbm-compat
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
