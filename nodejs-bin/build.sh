#!/bin/bash
set -e
name=nodejs-bin
_name=nodejs
homepage="https://nodejs.org/"
description="Evented I/O for V8 javascript - package built from precompiled binaries."
repo=$_name/node
version=$(gh_ver $repo)
filename="node-v$version-linux-x64.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://nodejs.org/dist/v$version/$filename"
unpk_enter "$filename" "$direname"
sudo cp -a "bin/." /usr/bin/
sudo cp -a "lib/." /usr/lib/
sudo cp -a "include/." /usr/include/
sudo cp -a "share/." /usr/share/
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
