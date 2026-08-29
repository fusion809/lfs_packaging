#!/bin/bash
set -e
name=gperf
version=$(gnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
lfs_depends=(gcc glibc make tar wget gzip)
if ! [[ -f $filename ]]; then
    wget -c https://ftpmirror.gnu.org/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --docdir=/usr/share/doc/$direname
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
