#!/bin/bash
set -e
name=libusb
repo=$name/$name
version=$(gh_ver $repo)
depends=(glibc systemd)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
# Some kernel modules required see libusb @ BLFS for details
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/v$version/$filename
fi
unpk_enter "$filename" "$direname"
options=(--prefix=/usr --disable-static)
cmi "${options[@]}"
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
