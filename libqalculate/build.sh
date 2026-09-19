#!/bin/bash
set -e
name=libqalculate
repo=Qalculate/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(curl icu libxml2)
ghr_download "Qalculate/libqalculate" "v$version" "$filename"
unpk_enter "$filename" "$direname"
configure_options=(--prefix=/usr    \
            --disable-static \
	    --docdir=/usr/share/doc/$direname)
cmi "${configure_options[@]}"
sudo rm -v /usr/lib/libqalculate.la
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
