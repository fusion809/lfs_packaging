#!/bin/bash
set -e
name=libpaper
repo=rrthomas/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/rrthomas/libpaper/releases/download/v$version/$filename
fi
unpk_enter "$filename" "$direname"
configure_options=(--prefix=/usr     \
            --sysconfdir=/etc \
            --disable-static  \
	    --docdir=/usr/share/doc/$direname)
cmi "${configure_options[@]}"
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
