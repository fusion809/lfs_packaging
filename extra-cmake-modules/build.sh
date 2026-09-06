#!/bin/bash
set -e
name=extra-cmake-modules
version=
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
