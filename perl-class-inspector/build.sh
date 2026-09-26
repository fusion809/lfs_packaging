#!/bin/bash
set -e
name=perl-class-inspector
homepage="https://search.cpan.org/dist/Class-Inspector"
description="Get information about a class and its structure"
_name=Class-Inspector
code=PLICEASE
version=$(perl_ver $name $_name $code)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(perl-file-sharedir)
perl_download $code $filename
unpk_enter "$filename" "$direname"
perl Makefile.PL &&
maki
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
