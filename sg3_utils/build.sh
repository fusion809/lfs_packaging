#!/bin/bash
set -e
name=sg3_utils
repo=doug-gilbert/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://sg.danny.cz/sg/p/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sudo autoreconf -fiv
sudo chown $USER -R .
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
