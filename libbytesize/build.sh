#!/bin/bash
set -e
name=libbytesize
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
