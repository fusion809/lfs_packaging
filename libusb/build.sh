#!/bin/bash
set -e
name=libusb
repo=$name/$name
version=$(gh_ver $repo)
depends=(glibc systemd)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
# Some kernel modules required see libusb @ BLFS for details
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr --disable-static)
cmi "${options[@]}"
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
