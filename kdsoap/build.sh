#!/bin/bash
set -e
name=kdsoap
repo=KDAB/KDSoap
version=$(gh_ver $repo)
depends=(brotli double-conversion e2fsprogs gcc glib2 glibc icu keyutils mitkrb openssl pcre2 systemd zlib zstd)
blfs_depends=(qt6)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/KDAB/KDSoap/releases/download/$direname/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr       -D CMAKE_BUILD_TYPE=Release  -D CMAKE_INSTALL_DOCDIR=/usr/share/doc/$direname)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
