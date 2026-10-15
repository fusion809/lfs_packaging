#!/bin/bash
set -e
name=cargo-tauri
_name=tauri
repo=tauri-apps/tauri
description="Command-line interface for building Tauri apps."
homepage="https://github.com/tauri-apps/tauri"
version=$(gh_ver $repo)
filename="$_name-v$version.tar.gz"
_direname="${filename/.tar.*/}"
direname="$_name-$_direname"
gha_download "$repo" "$_direname" "$filename"
unpk_enter "$filename" "$direname"
cargo build --release
sudo cp -r target/release/$name /usr/bin/
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
