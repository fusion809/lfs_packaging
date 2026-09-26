#!/bin/bash
set -e
name=lsb-tools
repo=lfs-book/LSB-Tools
version=$(gh_ver $repo)
filename="LSB-Tools-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
maki
sudo rm /usr/sbin/lsbinstall
sudo rm /usr/sbin/{install,remove}_initd
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
