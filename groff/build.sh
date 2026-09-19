#!/bin/bash
set -e
name=groff
version=$(gnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(gcc glibc gzip libICE libSM libX11 libXau libXaw libxcb libXdmcp libXext libXmu libXpm libXt make tar util-linux wget)
gnu_download $name $filename
unpk_enter "$filename" "$direname"
PAGE=A4 cmi --prefix=/usr
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
