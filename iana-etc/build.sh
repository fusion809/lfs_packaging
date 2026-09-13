#!/bin/bash
set -e
name=iana-etc
repo="Mic92/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/$version/$filename
fi

rm -rf $direname
tar xf $filename
cd $direname
sudo cp -v services protocols /etc
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
