#!/bin/bash
set -e
name=scdoc
version=$(wget -cqO- https://git.sr.ht/~sircmpwn/scdoc/refs | grep "/refs/[0-9]" | head -n 1 | cut -d '"' -f 2 | cut -d '/' -f 5)
direname="$name-$version"
filename="$direname.tar.gz"

if ! [[ -f $filename ]]; then
	wget -c https://git.sr.ht/~sircmpwn/scdoc/archive/$version.tar.gz -O "$filename"
fi

rm -rf $direname
tar xf "$filename"
cd "$direname"
make PREFIX=/usr -j$(nproc)
sudo make PREFIX=/usr install
cd ..
rm -rf "$direname"
echo "$version" > /var/lib/custom-packages/$name
