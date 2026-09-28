#!/bin/bash
set -e
name=fixit
repo=eugene-babichenko/$name
homepage="https://github.com/$repo"
description="A utility to fix mistakes in your commands."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(gcc glibc rust)
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
export RUSTUP_TOOLCHAIN=stable
export CARGO_TARGET_DIR=target
cargo build --locked --release
sudo install -Dm755 target/release/$name -t /usr/bin
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
