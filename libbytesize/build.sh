#!/bin/bash
set -e
name=libbytesize
homepage="https://github.com/storaged-project/libbytesize"
description="A tiny library providing a C "class" for working with arbitrary big sizes in bytes"
repo="storaged-project/libbytesize"
version=$(gh_ver $repo)
depends=(glibc gmp mpfr pcre2)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --with-gtk-doc=no
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
