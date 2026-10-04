#!/bin/bash
set -e
name=sagemath
_name=sage
repo=$name/$_name
homepage="https://www.sagemath.org/"
description="A free open-source mathematics software system building on others."
version=$(gh_ver $repo)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://mirror.aarnet.edu.au/pub/sage/src/$filename"
unpk_enter "$filename" "$direname"
sudo mkdir -p /opt/$direname
sudo useradd -m builder
sudo chown builder /opt/$direname . -R
sudo -u builder -H bash -c "
./configure --prefix=/opt/$direname --with-sage-venv=yes
make -j$(nproc)
"
sudo make install
sudo chown root:root -R /opt/$direname
cd ..
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
