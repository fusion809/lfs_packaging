#!/bin/bash
set -e
_name=gh
name=$_name-bin
repo=cli/cli
homepage="https://github.com/cli/cli"
description="GitHub's modern command-line client - version built from precompiled binary."
version=$(gh_ver $repo)
filename="${_name}_${version}_linux_amd64.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
#mkdir pkg
pkg=/
#pkg=pkg
#sudo mkdir -p $pkg/usr/{bin,share/man/man1}
sudo cp -r bin/* $pkg/usr/bin/
sudo cp -r share/man/man1/* $pkg/usr/share/man/man1
#sudo du -sh $pkg
cd ../
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
