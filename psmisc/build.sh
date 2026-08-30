#!/bin/bash
set -e
name=psmisc
version=$(gl_ver $name/$name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
lfs_depends=(ncurses make gcc tar xz coreutils)
if ! [[ -f $filename ]]; then
	wget -c https://sourceforge.net/projects/psmisc/files/psmisc/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr
cd ..
echo $version > /var/lib/custom-packages/$name
