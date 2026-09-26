#!/bin/bash
set -e
name=perl-file-sharedir
homepage="https://metacpan.org/dist/File-ShareDir"
description="Locate per-dist and per-module shared files"
_name=File-ShareDir
code=REHSACK
version=$(perl_ver $name $_name $code)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(perl-file-sharedir-install)
perl_download "$code" "$filename"
unpk_enter "$filename" "$direname"
perl Makefile.PL &&
maki
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
