#!/bin/bash
set -e
name=enchant
repo="rrthomas/enchant"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
blfs_depends=(aspell glib2 vala)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/rrthomas/enchant/releases/download/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
configure_options=(--prefix=/usr     \
            --sysconfdir=/etc \
            --disable-static  \
	    --docdir=/usr/share/doc/$direname)
cmi "${configure_options[@]}"
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
