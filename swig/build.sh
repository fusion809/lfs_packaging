#!/bin/bash
set -e
name=swig
repo=$name/$name
version=$(gh_ver $repo)
depends=(gcc glibc pcre2 zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://downloads.sourceforge.net/swig/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr
sudo cp -v -R Doc -T /usr/share/doc/$direname
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
