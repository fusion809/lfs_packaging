#!/bin/bash
set -e
name=rnnoise
description="Noise-suppression library based on recurrent neural network."
homepage="https://gitlab.xiph.org/xiph/rnnoise"
version=$(timeout 10 git ls-remote --tags --refs $homepage.git | grep "v[0-9.]+" -oE | sed 's/v//g' | tail -n 1)
filename="$name-v$version.tar.gz"
direname="${filename/.tar.*/}"
model=$(wget -cqO- -T 5 -t 1 "https://gitlab.archlinux.org/archlinux/packaging/packages/rnnoise/-/raw/main/PKGBUILD?ref_type=heads" | grep "_model_version=" | cut -d '=' -f 2 | cut -d ' ' -f 1)
model_filename=rnnoise_data-$model.tar.gz
download_src "$homepage/-/archive/v$version/$filename"
download_src "https://media.xiph.org/rnnoise/models/$model_filename"
unpk_enter "$filename" "$direname"
tar xf ../$model_filename
cmi --prefix=/usr --disable-static --enable-x86-rtcd
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
