#!/bin/bash
set -e
name=iptables
repo=cernekee/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
# Kernel options are required, too
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://www.netfilter.org/projects/iptables/files/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --disable-nftables --enable-libipq
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
