#!/bin/bash
set -e
name=gmp
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gcc glibc make ncurses tar wget xz)
gnu_download $name $filename
rm -rf $direname
tar xf $filename
cd $direname
sed -i '/long long t1;/,+1s/()/(...)/' configure
./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
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
echo "$version" sudo tee /var/lib/custom-packages/$name
