#!/bin/bash
set -e
name=woxi-git
_name=Woxi
repo=ad-si/$_name
homepage="https://github.com/ad-si/Woxi"
description="Open-source Mathematica alternative written in Rust - git build."
#version=$(gh_com $repo)
version=4b365dae1c8c2adb022bf34d6a8cf637225819bb
depends=(gcc glibc rust)
conflicts=(woxi)
download_github "$repo"
cd $_name
git checkout $version
srcdir=$PWD
cargo build --release
sudo install -Dm755 target/release/woxi /usr/bin/
cd woxi-studio
cargo build --release
if [[ -f $srcdir/target/release/woxi-studio ]]; then
	sudo cp -r $srcdir/target/release/woxi-studio /usr/bin
else
	echo "No target/release/woxi-studio, looking for woxi-studio to install it..."
	find $srcdir -type f -name "woxi-studio" -print \
		-exec sudo install -Dm755 {} "/usr/bin/{}" \;
fi
rm -rf $srcdir/target/release/woxi*
cd ../..
wget -c https://woxi.ad-si.com/docs/favicon.png -O woxi.png
sudo install -Dm644 woxi.png /usr/share/pixmaps/
sudo rm woxi.png
sudo tee /usr/share/applications/woxi-studio.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Woxi Studio
Comment=Native notebook editor for the Wolfram Language
Exec=/usr/bin/woxi-studio
TryExec=/usr/bin/woxi-studio
Icon=woxi
Terminal=false
Categories=Education;Science;Math;
StartupNotify=true
EOF
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
