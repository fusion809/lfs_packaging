#!/bin/bash
set -e
name=mypaint-brushes
repo=mypaint/$name
homepage="https://github.com/mypaint/mypaint-brushes"
description="Provides brushes used by packages which use libmypaint."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
