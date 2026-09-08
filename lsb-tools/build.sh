#!/bin/bash
set -e
name=lsb-tools
repo=lfs-book/LSB-Tools
version=$(gh_ver $repo)
filename="LSB-Tools-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/releases/download/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
maki
sudo rm /usr/sbin/lsbinstall
sudo rm /usr/sbin/{install,remove}_initd
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
