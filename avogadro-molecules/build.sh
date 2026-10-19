#!/bin/bash
set -e
name=avogadro-molecules
_name=molecules
repo=OpenChemistry/$_name
homepage="https://openchemistry.org/"
description="Common molecule fragments for visualization."
version=$(gh_ver $repo)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cd ..
sudo mkdir -p /usr/share/avogadro2
sudo cp -ar $direname /usr/share/avogadro2/molecules
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
