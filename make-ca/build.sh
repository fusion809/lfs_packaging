#!/bin/bash
set -e
name=make-ca
repo=lfs-book/make-ca
version=$(gh_ver "$repo")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
sed '/mktemp/s/-t //' -i make-ca
sudo make install
sudo install -vdm755 /etc/ssl/local
sudo /usr/sbin/make-ca -g --force
sudo systemctl enable update-pki.timer
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee /var/lib/custom-packages/$name
