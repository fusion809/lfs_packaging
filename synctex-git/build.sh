#!/bin/bash
set -e
name=synctex
_name=synctex
repo=jlaurens/$_name
homepage="https://github.com/jlaurens/synctex"
description="SyncTeX parser library and CLI."
version=$(timeout 5 git ls-remote https://github.com/jlaurens/synctex.git refs/heads/2026-1 | sed 's/\s.*//g')
depends=(glibc texlive zlib)
download_git "https://github.com/jlaurens/synctex"
cd synctex
git checkout 2026-1
cd meson
sed -i 's/build_always[[:space:]]*:[[:space:]]*true/build_by_default: false/' meson.build
mni --prefix=/usr --buildtype=release
cd ../../..
rm -rf synctex
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
