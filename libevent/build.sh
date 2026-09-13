#!/bin/bash
set -e
name=libevent
repo=$name/$name
version=$(gh_ver $repo | sed 's/-stable//g')
depends=(glibc openssl)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version-stable.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/release-$version-stable/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i 's/python/&3/' event_rpcgen.py
options=(--prefix=/usr --disable-static)
cmi "${options[@]}"
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
