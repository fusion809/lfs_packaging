#!/bin/bash
name=libtool
version=$(wget -cqO- https://ftp.gnu.org/gnu/libtool/ | grep "libtool-[0-9.]*.tar.xz\"" | tail -n 1 | cut -d '"' -f 8 | sed 's/.tar.xz//g' | sed 's/libtool-//g')
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
