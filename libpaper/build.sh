#!/bin/bash
set -e
name=libpaper
repo=rrthomas/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
configure_options=(--prefix=/usr     \
            --sysconfdir=/etc \
            --disable-static  \
	    --docdir=/usr/share/doc/$direname)
cmi "${configure_options[@]}"
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
