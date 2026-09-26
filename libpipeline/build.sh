#!/bin/bash
set -e
name=libpipeline
homepage="https://nongnu.org/libpipeline/"
description="a C library for manipulating pipelines of subprocesses in a flexible and convenient way"
version=$(ngnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gcc glibc make tar wget xz)
get_ngnu $filename $direname $name $version
cmi --prefix=/usr --disable-static --sysconfdir=/etc --docdir=/usr/share/doc/$direname
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
