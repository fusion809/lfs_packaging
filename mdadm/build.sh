#!/bin/bash
set -e
name=mdadm
repo=md-raid-utilities/$name
version=$(gh_ver $repo)
depends=(glibc systemd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
# Kernel options required
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://git.kernel.org/pub/scm/utils/mdadm/mdadm.git/snapshot/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
make -j$(nproc)
sudo make BINDIR=/usr/sbin install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
