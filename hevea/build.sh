#!/bin/bash
set -e
name=hevea
repo=maranget/$name
homepage="http://pauillac.inria.fr/~maranget/hevea"
description="Fast LaTeX to HTML translator."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://hevea.inria.fr/distri/$filename"
unpk_enter "$filename" "$direname"
make PREFIX=/usr
sudo make install
sudo mkdir -p /usr/share/texmf/tex/latex
sudo ln -s /usr/lib/hevea/hevea.sty /usr/share/texmf/tex/latex/hevea.sty
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
