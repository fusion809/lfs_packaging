#!/bin/bash
set -e
name=procps-ng
version=$(gl_ver $name/procps $name)
lfs_depends=(gcc glibc tar make coreutils wget xz)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://sourceforge.net/projects/procps-ng/files/Production/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
configure_options=(--prefix=/usr                           \
            --docdir=/usr/share/doc/$direname \
            --disable-static                        \
            --disable-kill                          \
            --enable-watch8bit                      \
	    --with-systemd)
cmi "${configure_options[@]}"
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
