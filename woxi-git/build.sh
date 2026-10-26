#!/bin/bash
set -e
name=woxi-git
_name=Woxi
repo=ad-si/$_name
homepage="https://github.com/ad-si/Woxi"
description="Open-source Mathematica alternative written in Rust - git build."
version=$(gh_com $repo)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cargo build --release
sudo install -Dm755 target/release/woxi /usr/bin/
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
wget -c https://woxi.ad-si.com/docs/favicon.png -O woxi.png
sudo install -Dm644 woxi.png /usr/share/pixmaps/
sudo rm woxi.png
sudo install -Dm644 woxi-studio.desktop /usr/share/applications
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
