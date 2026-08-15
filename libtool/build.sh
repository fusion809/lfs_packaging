#!/bin/bash
name=libtool
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"

if ! [[ -f $filename ]]; then
	wget -c https://ftp.gnu.org/gnu/libtool/$filename
fi

tar xf $filename
cd "$direname"
./configure --prefix=/usr
make -j$(nproc)
sudo make install
sudo rm -fv /usr/lib/libltdl.a
cd ..
echo "$version" > /var/lib/custom-packages/$name
