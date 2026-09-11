#!/bin/bash
set -e
name=mpfr
version=$(gnu_ver $name)
depends=(glibc gmp)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gnu_download $name $filename
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=( --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
	    --docdir=/usr/share/doc/$direname)
./configure "${options[@]}"
make -j$(nproc)
make -j$(nproc) html
if ! (make check); then
	passes=$(cat $(find -name '*.log') | grep -c ^PASS | wc -l)
	read -p "$passes tests passed. Proceed to installation anyway? [y/N] " -n 1 -r < /dev/tty
	echo
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		exit 1
	fi
fi
sudo make install
sudo make install-html
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
