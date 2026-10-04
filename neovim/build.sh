#!/bin/bash
set -e
name=neovim
repo=$name/$name
homepage="https://neovim.io"
description="Vim fork focused on extensibility and usability."
version=$(gh_ver $repo)
depends=(gcc glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=/usr
sudo make CMAKE_INSTALL_PREFIX=/usr install
cd ../
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
