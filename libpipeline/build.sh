#!/bin/bash
set -e
name=libpipeline
version=$(ngnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
lfs_depends=(gcc glibc make tar wget xz)
get_ngnu $filename $direname $name $version
cmi --prefix=/usr --disable-static --sysconfdir=/etc --docdir=/usr/share/doc/$direname
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
