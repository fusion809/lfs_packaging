#!/bin/bash
set -e
name=sassc
homepage="https://sass-lang.com"
description="C implementation of Sass CSS preprocessor"
repo=sass/$name
version=$(gh_ver $repo)
librepo=sass/libsass
libver=$(gh_ver $librepo)
depends=(gcc glibc)
filename="$name-$version.tar.gz"
echo "filename=$filename"
libfilename="libsass-$libver.tar.gz"
libdirename="${libfilename/.tar.*/}"
echo "libfilename=$libfilename"
echo "libdirename=$libdirename"
direname="${filename/.tar.*/}"
echo "direname=$direname"
gha_download "$repo" "$version" "$filename"
gha_download "$librepo" "$libver" "$libfilename"
unpk_enter "$libfilename" "$libdirename"
sudo autoreconf -fi
sudo chown $USER -R .
cmi --prefix=/usr --disable-static
cd ..
unpk_enter "$filename" "$direname"
sudo autoreconf -fi
sudo chown $USER -R .
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname" "$libfilename" "$libdirename"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
