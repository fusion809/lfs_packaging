#!/bin/bash
set -e
name=perl-file-sharedir-install
homepage="https://search.cpan.org/dist/File-ShareDir-Install"
description="File::ShareDir::Install - Install read-only data files from a distribution"
_name=File-ShareDir-Install
code=ETHER
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
