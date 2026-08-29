#!/bin/bash
set -e
name=groff
version=$(gnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
lfs_depends=(gcc glibc gzip make tar util-linux wget)
blfs_depends=(libXau libXdmcp libxcb)
depends=(gcc libICE libSM libX11 libXaw libXext libXmu libXpm libXt)
if ! [[ -f $filename ]]; then
    wget -c https://ftpmirror.gnu.org/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
PAGE=A4 cmi --prefix=/usr
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
