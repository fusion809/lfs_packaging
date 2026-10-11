#!/bin/bash
set -e
name=pdfcraft
repo=storytold/$name
description="An open-source, clean-room reimplementation of Adobe Acrobat built in pure Rust."
homepage="https://getartcraft.com/apps/pdfcraft"
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
cargo build --release
sudo cp -r "target/release/$name"{,-cli} /usr/bin/
sudo cp -r "packaging/linux/ai.storyteller.$name.desktop" "/usr/share/applications/"
sudo cp -r "packaging/linux/ai.storyteller.$name.mime.xml" "/usr/share/mime/packages/" 
sudo cp -r assets/app-icon/hicolor/scalable/apps/ai.storyteller.$name.svg "/usr/share/icons/hicolor/scalable/"
for s in ${_icons[@]}; do
	dim="${s}x${s}"
	sudo cp -r assets/app-icon/hicolor/$dim/apps/ai.storyteller.$name.png "/usr/share/icons/hicolor/$dim/apps/"
done
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
