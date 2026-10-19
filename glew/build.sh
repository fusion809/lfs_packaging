#!/bin/bash
set -e
name=glew
repo=nigels-com/$name
homepage="https://github.com/nigels-com/glew"
description="The OpenGL Extension Wrangler Library."
version=$(gh_ver $repo)
filename="$name-$version.tgz"
direname="${filename/.tgz/}"
ghr_download "$repo" "$direname" "$filename"
unpk_enter "$filename" "$direname"
arch_patch $name glew-2.3.0-install.patch
arch_patch $name glew-ldflags.patch
make STRIP=
sudo make install.all DESTDIR=/
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
