#!/bin/bash
set -e
name=iana-etc
homepage="https://www.iana.org/protocols"
description="/etc/protocols and /etc/services provided by IANA"
repo="Mic92/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
sudo cp -v services protocols /etc
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
