#!/bin/bash
set -e
name=gh
_name=cli
homepage="https://github.com/cli/cli"
repo=$_name/$_name
version=$(gh_ver $repo)
filename="${_name}-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
maki prefix=/usr
cd ../
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
