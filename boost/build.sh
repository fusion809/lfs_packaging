#!/bin/bash
set -e
name=boost
repo=boostorg/$name
version=$(gh_ver $repo)
filename="$name-$version-b2-nodocs.tar.xz"
direname="$name-$version"
depends=(which)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/releases/download/$direname/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
./bootstrap.sh --prefix=/usr --with-python=python3 &&
./b2 stage -j$(nproc) threading=multi link=shared
sudo ./b2 install threading=multi link=shared
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
