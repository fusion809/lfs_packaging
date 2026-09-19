#!/bin/bash
set -e
name=libevent
repo=$name/$name
version=$(gh_ver $repo | sed 's/-stable//g')
depends=(glibc openssl)
filename="$name-$version-stable.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "release-$version-stable" "$filename"
unpk_enter "$filename" "$direname"
sed -i 's/python/&3/' event_rpcgen.py
options=(--prefix=/usr --disable-static)
cmi "${options[@]}"
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
