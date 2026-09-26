#!/bin/bash
set -e
name=graphene
homepage="https://ebassi.github.io/graphene/"
description="Thin layer of graphic data types"
repo=ebassi/$name
version=$(gh_ver $repo)
majVer=$(echo $version | sed -E 's/.[0-9]+//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(glib2)
gn_download "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
