#!/bin/bash
set -e
name=man-db
homepage="https://gitlab.com/man-db/man-db"
description="A utility for reading man pages"
version=$(gl_ver $name/$name)
depends=(bash coreutils gcc glibc make tar xz)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://download.savannah.gnu.org/releases/$name/$filename"
unpk_enter "$filename" "$direname"
configure_options=(--prefix=/usr                         \
            --docdir=/usr/share/doc/$direname \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap)
cmi "${configure_options[@]}"
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
