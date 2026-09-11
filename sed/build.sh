#!/bin/bash
set -e
name=sed
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(acl attr gcc glibc make tar wget xz pcre2)
gnu_download "$name" "$filename"
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr html
sudo install -vDm644 doc/sed.html -t /usr/share/doc/$direname
cd ..
rm -rf $filename $direname
echo "$version" sudo tee /var/lib/custom-packages/$name
