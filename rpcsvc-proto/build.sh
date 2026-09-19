#!/bin/bash
set -e
name=rpcsvc-proto
repo=thkukuk/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/v$version/$filename
fi
unpk_enter "$filename" "$direname"
cmi --sysconfdir=/etc
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
