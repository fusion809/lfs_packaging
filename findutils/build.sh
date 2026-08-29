#!/bin/bash
set -e
name=findutils
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
lfs_depends=(glibc gcc make tar wget xz)
if ! [[ -f $filename ]]; then
    wget -c https://ftpmirror.gnu.org/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --localstatedir=/var/lib/locate
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name