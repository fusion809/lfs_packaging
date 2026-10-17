#!/bin/bash
set -e
name=discount
repo=Orc/$name
homepage="http://www.pell.portland.or.us/~orc/Code/discount"
description="C implementation of John Gruber's Markdown markup language."
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --shared
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
