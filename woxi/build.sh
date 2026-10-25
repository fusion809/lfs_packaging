#!/bin/bash
set -e
name=woxi
_name=Woxi
repo=ad-si/$name
homepage="https://woxi.ad-si.com/"
description="Mathematica reimplementation in Rust."
version=$(gh_ver $repo)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
export CARGO_HOME="$PWD"
export CARGO_PROFILE_RELEASE_DEBUG=0
export CARGO_PROFILE_RELEASE_STRIP=debuginfo
export CARGO_PROFILE_RELEASE_LTO=thin
export CARGO_PROFILE_RELEASE_CODEGEN_UNITS=1
export CARGO_PROFILE_RELEASE_OPT_LEVEL=3
export CARGO_TARGET_DIR=target
export RUSTUP_TOOLCHAIN=stable
cargo build --release
sudo cp -r target/release/$name /usr/bin
cd woxi-studio
cargo build --release
if [[ -f target/release/$name-studio ]]; then
	sudo cp -r target/release/$name-studio /usr/bin
else
	echo "No target/release/$name-studio, looking for $name-studio to install it..."
	find -type f -name "woxi-studio" -print \
		-exec sudo install -Dm755 {} "/usr/bin/{}" \;
fi
cd ../..
sudo install -Dm644 woxi.png /usr/share/pixmaps/
sudo install -Dm644 woxi-studio.desktop /usr/share/applications
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
