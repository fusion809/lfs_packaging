#!/bin/bash
set -e
name=thefuck
repo=lyda/$name
version=$(gh_com $repo)
homepage="https://github.com/$repo"
description="Correct command line mistakes"
depends=(go)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
make build
sudo install -Dm755 bin/$name /usr/bin/
sudo install -Dm755 ../fuck.sh /etc/profile.d/fuck.sh
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
