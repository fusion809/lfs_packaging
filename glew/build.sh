#!/bin/bash
set -e
name=glew
repo=nigels-com/$name
homepage="https://github.com/nigels-com/glew"
description="The OpenGL Extension Wrangler Library."
version=$(gh_ver $repo)
filename="$name-$version.tgz"
direname="${filename/.tgz/}"
gha_download "$repo" "$direname" "$filename"
unpk_enter "$filename" "$direname"
arch_patch $name
make STRIP=
sudo make install.all DESTDIR=/
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
