#!/bin/bash
set -e
name=mdadm
homepage="https://git.kernel.org/pub/scm/utils/mdadm"
description="A tool for managing/monitoring Linux md device arrays, also known as Software RAID"
repo=md-raid-utilities/$name
version=$(gh_ver $repo)
depends=(glibc systemd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
# Kernel options required
download_src "https://git.kernel.org/pub/scm/utils/mdadm/mdadm.git/snapshot/$filename"
unpk_enter "$filename" "$direname"
make -j$(nproc)
sudo make BINDIR=/usr/sbin install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
