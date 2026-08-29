#!/bin/bash
set -e
name=bison
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
lfs_depends=(gcc gettext glibc make ncurses tar wget xz)
if ! [[ -f $filename ]]; then
    wget -c https://ftpmirror.gnu.org/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --docdir=/usr/share/doc/"$direname"
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name