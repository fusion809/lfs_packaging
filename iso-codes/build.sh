#!/bin/bash
set -e
name=iso-codes
repo=iso-codes-team/$name
version=$(sd_ver $repo)
filename="$name-v$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://salsa.debian.org/iso-codes-team/iso-codes/-/archive/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
mni --prefix=/usr
cd ../...
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
