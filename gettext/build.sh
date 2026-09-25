#!/bin/bash
set -e
name=gettext
homepage="https://gnu.org/s/gettext/"
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gcc glibc make ncurses readline tar wget xz)
gnu_download $name $filename
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static --docdir=/usr/share/doc/$direname
sudo chmod -v 0755 /usr/lib/preloadable_libintl.so
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
