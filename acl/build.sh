#!/bin/bash
set -e
name=acl
version=$(ngnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
lfs_depends=(gcc glibc make tar wget xz)
if ! [[ -f $filename ]]; then
    wget -c https://download.savannah.nongnu.org/releases/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --disable-static --sysconfdir=/etc --docdir=/usr/share/doc/$direname
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
