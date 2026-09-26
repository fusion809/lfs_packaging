#!/bin/bash
set -e
name=perl-uri
homepage="https://search.cpan.org/dist/URI/"
description="Uniform Resource Identifiers (absolute and relative)"
_name=URI
code=OALDERS
version=$(perl_ver $name $_name $code)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
perl_download "$code" "$filename"
unpk_enter "$filename" "$direname"
perl Makefile.PL &&
maki
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
