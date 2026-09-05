#!/bin/bash
set -e
name=duktape
repo="svaarala/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://duktape.org/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i 's/-Os/-O2/' Makefile.sharedlibrary
maki -f Makefile.sharedlibrary INSTALL_PREFIX=/usr
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
