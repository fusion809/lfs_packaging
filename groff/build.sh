#!/bin/bash
set -e
name=groff
homepage="https://www.gnu.org/software/groff/groff.html"
description="GNU troff text-formatting system"
version=$(gnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(gcc glibc gzip libice libSM libx11 libxau libxaw libxcb libxdmcp libxext libxmu libxpm libxt make tar util-linux wget)
gnu_download $name $filename
unpk_enter "$filename" "$direname"
PAGE=A4 cmi --prefix=/usr
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
