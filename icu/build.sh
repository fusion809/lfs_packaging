#!/bin/bash
set -e
name=icu
repo="unicode-org/$name"
version=$(gh_ver $repo)
filename="${name}4c-$version-sources.tgz"
direname="${filename/.tgz/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/releases/download/release-$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "icu/source"
cmi --prefix=/usr
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
