#!/bin/bash
set -e
name=man-db
version=$(gl_ver $name/$name)
lfs_depends=(gcc make glibc tar xz coreutils bash)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.savannah.gnu.org/releases/$name/$filename
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
echo "$version" > /var/lib/custom-packages/$name
