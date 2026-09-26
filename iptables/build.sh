#!/bin/bash
set -e
name=iptables
description="Linux kernel packet control tool (using nft interface)"
homepage="https://www.netfilter.org/projects/iptables/"
repo=cernekee/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
# Kernel options are required, too
download_src "https://www.netfilter.org/projects/iptables/files/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-nftables --enable-libipq
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
