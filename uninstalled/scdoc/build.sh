#!/bin/bash
set -e
name=scdoc
version=$(wget -cqO- https://git.sr.ht/~sircmpwn/scdoc/refs | grep "/refs/[0-9]" | head -n 1 | cut -d '"' -f 2 | cut -d '/' -f 5)
direname="$name-$version"
filename="$direname.tar.gz"
download_src "https://git.sr.ht/~sircmpwn/scdoc/archive/$version.tar.gz" "$filename"
unpk_enter "$filename" "$direname"
maki "PREFIX=/usr"
cd ..
rm -rf "$direname" "$filename"
echo "$version" | sudo tee /var/lib/custom-packages/$name
