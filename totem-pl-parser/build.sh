#!/bin/bash
set -e
name=totem-pl-parser
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(acl bzip2 gcc glib2 glibc icu libarchive libffi libgcrypt libgpg-error libxml2 lz4 openssl pcre2 systemd util-linux xz zlib zstd)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr --buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
