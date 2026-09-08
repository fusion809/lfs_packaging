#!/bin/bash
set -e
name=libpcap
repo=the-tcpdump-group/$name
version=$(gh_ver $repo)
depends=(dbus glibc systemd)
blfs_depends=(libnl)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.tcpdump.org/release/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
./configure --prefix=/usr
make -j$(nproc)
sed -i '/INSTALL_DATA.*libpcap.a\|RANLIB.*libpcap.a/ s/^/#/' Makefile
sudo make install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
