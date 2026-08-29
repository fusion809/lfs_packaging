#!/bin/bash
set -e
name=binutils
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://sourceware.org/pub/$name/releases/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
mkdir -v build
cd       build
[ -f ../configure ] || (cd .. && autoreconf -fiv)
../configure --prefix=/usr        --sysconfdir=/etc    --enable-ld=default  --enable-plugins     --enable-shared      --disable-werror     --enable-64-bit-bfd  --enable-new-dtags   --with-system-zlib   --with-lib-path=/usr/lib  --enable-default-hash-style=gnu
make -j$(nproc) tooldir=/usr
if ! (make -k check); then
	grep '^FAIL:' $(find -name '*.log')
	read -p 'Build failed tests. Proceed to installation anyway? [y/N] ' -n 1 -r < /dev/tty
	echo
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		exit 1
	fi
fi
sudo make tooldir=/usr install
sudo rm -rfv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a  /usr/share/doc/gprofng/
cd ../..
rm -rf $direname $filename
echo "$version" > /var/lib/custom-packages/$name
