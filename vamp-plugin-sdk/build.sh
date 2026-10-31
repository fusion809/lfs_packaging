#!/bin/bash
set -e
name=vamp-plugin-sdk
repo=vamp-plugins/$name
homepage="https://github.com/vamp-plugins/vamp-plugin-sdk"
description="Vamp audio analysis plugin system."
version=$(gh_ver $repo)
filename="$name-$name-v$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$name-v$version" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
