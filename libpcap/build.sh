#!/bin/bash
set -e
name=libpcap
description="A system-independent interface for user-level packet capture"
homepage="https://www.tcpdump.org/"
repo=the-tcpdump-group/$name
version=$(gh_ver $repo)
depends=(dbus glibc libnl systemd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://www.tcpdump.org/release/$filename"
unpk_enter "$filename" "$direname"
./configure --prefix=/usr
make -j$(nproc)
sed -i '/INSTALL_DATA.*libpcap.a\|RANLIB.*libpcap.a/ s/^/#/' Makefile
sudo make install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
