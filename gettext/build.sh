#!/bin/bash
set -e
name=gdbm
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
lfs_depends=(gcc glibc make ncurses readline tar wget xz)
if ! [[ -f $filename ]]; then
    wget -c https://ftpmirror.gnu.org/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --disable-static --docdir=/usr/share/doc/$direname
sudo chmod -v 0755 /usr/lib/preloadable_libintl.so
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
