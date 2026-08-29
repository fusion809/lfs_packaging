#!/bin/bash
set -e
name=grep
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
lfs_depends=(gcc glibc make tar wget xz)
depends=(pcre2)
if ! [[ -f $filename ]]; then
    wget -c https://ftpmirror.gnu.org/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
sed -i "s/echo/#echo/" src/egrep.sh
cmi --prefix=/usr
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
