#!/bin/bash
set -e
name=gh-bin
repo=cli/cli
homepage="https://github.com/cli/cli"
description="GitHub's modern command-line client - version built from precompiled binary."
version=$(gh_ver $repo)
filename="${name}_${version}_linux_amd64.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
sudo cp -r bin/* /usr/bin/
sudo cp -r share/man/man1/* /usr/share/man/man1
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
