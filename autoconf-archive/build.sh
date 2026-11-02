#!/bin/bash
set -e
name=autoconf-archive
homepage="http://www.gnu.org/software/autoconf-archive/"
description="A collection of freely re-usable autoconf macros."
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gnu_download "$name" "$filename"
unpk_enter "$filename" "$direname"
wget -c "https://cgit.git.savannah.gnu.org/cgit/autoconf-archive.git/patch/?id=241f7ae5f857b0c9bab7866b79b4e47587126b96" -O autoconf.patch
patch -Np1 -i autoconf.patch
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
