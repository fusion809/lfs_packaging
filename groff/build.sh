#!/bin/bash
set -e
name=groff
version=$(gnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(gcc glibc gzip make tar util-linux wget libXau libXdmcp libxcb libICE libSM libX11 libXaw libXext libXmu libXpm libXt)
gnu_download $name $filename
rm -rf $direname
tar xf $filename
cd $direname
PAGE=A4 cmi --prefix=/usr
cd ..
rm -rf $filename $direname
echo "$version" sudo tee /var/lib/custom-packages/$name
