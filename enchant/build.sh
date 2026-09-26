#!/bin/bash
set -e
name=enchant
description="A wrapper library for generic spell checking"
repo="rrthomas/enchant"
homepage="https://rrthomas.github.io/enchant/"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(aspell glib2 vala)
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
configure_options=(
    --prefix=/usr     \
    --sysconfdir=/etc \
    --disable-static  \
    --docdir=/usr/share/doc/$direname
)
cmi "${configure_options[@]}"
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
