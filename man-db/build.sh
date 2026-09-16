#!/bin/bash
set -e
name=man-db
version=$(gl_ver $name/$name)
depends=(bash coreutils gcc glibc make tar xz)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.savannah.gnu.org/releases/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
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
