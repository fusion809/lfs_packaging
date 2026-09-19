#!/bin/bash
set -e
name=libuv
repo=$name/$name
version=$(gh_ver $repo)
filename="$name-v$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://dist.libuv.org/dist/v$version/$filename"
unpk_enter "$filename" "$direname"
sudo ./autogen.sh
sudo chown $USER -R .
cmi --prefix=/usr --disable-static
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
