#!/bin/bash
set -e
name=yodl
repo=fbb-git/$name
version=$(gl_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.com/$repo/-/archive/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"/yodl
./build programs
./build macros
./build man
./build manual
sudo su -c "./build install programs /
        ./build install macros /
        ./build install man /
        ./build install manual /"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
