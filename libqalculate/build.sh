#!/bin/bash
set -e
name=libqalculate
repo=Qalculate/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(curl icu libxml2)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/Qalculate/libqalculate/releases/download/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
configure_options=(--prefix=/usr    \
            --disable-static \
	    --docdir=/usr/share/doc/$direname)
cmi "${configure_options[@]}"
sudo rm -v /usr/lib/libqalculate.la
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
