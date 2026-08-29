#!/bin/bash
set -e
name=mpfr
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
lfs_depends=(gcc glibc make ncurses tar wget xz)
if ! [[ -f $filename ]]; then
    wget -c https://ftpmirror.gnu.org/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
./configure --prefix=/usr        \
            --enable-thread-safe \
            --disable-static     \
            --docdir=/usr/share/doc/$direname
make -j$(nproc)
make -j$(nproc) html

if ! (make check); then
	passes=$(cat $(find -name '*.log') | grep -c ^PASS | wc -l)
	read -p "$passes tests passed. A minimum of 199 should have passed. Proceed to installation anyway? [y/N] " -n 1 -r < /dev/tty
	echo
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		exit 1
	fi
fi
sudo make install
sudo make install-html
cd ../..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
