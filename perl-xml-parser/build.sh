#!/bin/bash
set -e
name=perl-xml-parser
homepage="https://github.com/cpan-authors/XML-Parser"
description="Expat-based XML parser module for perl"
_name=XML-Parser
code=TODDR
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
