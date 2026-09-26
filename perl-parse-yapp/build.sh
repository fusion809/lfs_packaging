#!/bin/bash
set -e
name=perl-parse-yapp
homepage="https://search.cpan.org/dist/Parse-Yapp"
description="Perl/CPAN Module Parse::Yapp : Generates OO LALR parser modules"
_name=Parse-Yapp
code=WBRASWELL
version=$(perl_ver $name $_name $code)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
perl_download $code $filename
unpk_enter "$filename" "$direname"
perl Makefile.PL &&
maki
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
