#!/bin/bash
set -e
name=nodejs-bin
_name=nodejs
repo=$_name/node
version=$(gh_ver $repo)
filename="node-v$version-linux-x64.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://nodejs.org/dist/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
sudo cp -a "$direname/bin/." /usr/bin/
sudo cp -a "$direname/lib/." /usr/lib/
sudo cp -a "$direname/include/." /usr/include/
sudo cp -a "$direname/share/." /usr/share/
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
