#!/bin/bash
set -e
name=rust-bin
_name=rust
repo=$_name-lang/$_name
homepage="https://www.rust-lang.org/"
description="Systems programming language with modern features - binary package."
version=$(gh_ver $repo)
filename="rust-$version-x86_64-unknown-linux-gnu.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://static.rust-lang.org/dist/$filename"
unpk_enter "$filename" "$direname"
mkdir pkg
sudo ./install.sh --prefix=/usr
cd ../
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
