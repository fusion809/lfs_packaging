#!/bin/bash
set -e
name=artcraft
repo=storytold/$name
description="An open-source, clean-room reimplementation of Adobe Acrobat built in pure Rust."
homepage="https://getartcraft.com/apps/artcraft"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
export CARGO_HOME="$srcdir"
export CARGO_PROFILE_RELEASE_DEBUG=2
export CARGO_PROFILE_RELEASE_STRIP=false
export CARGO_PROFILE_RELEASE_LTO=thin
export CARGO_PROFILE_RELEASE_CODEGEN_UNITS=1
export CARGO_PROFILE_RELEASE_OPT_LEVEL=3
export CARGO_TARGET_DIR=target
export RUSTUP_TOOLCHAIN=stable
CFLAGS+=' -fno-lto'
RUSTFLAGS+=" --remap-path-prefix $PWD=/"
export SQLX_OFFLINE=true
pushd frontend
npm ci --allow-git=all --dangerously-allow-all-scripts --no-audit --no-fund
env \
		VITE_ENVIRONMENT_TYPE=production \
		NODE_OPTIONS=--max-old-space-size=8192 \
		npx nx run artcraft:build
popd
cargo build --frozen --release --features tauri/custom-protocol
sudo cp -r "target/release/$name" /usr/bin/
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
