#!/bin/bash
set -e
name=mpfi
repo=arpra-project/$name
homepage="http://perso.ens-lyon.fr/nathalie.revol/software.html"
description="Interval arithmetic C library."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
sudo autoreconf -fiv
sudo chown $USER -R .
CFLAGS+=" -Wno-incompatible-pointer-types" \
cmi --prefix=/usr --disable-static --enable-shared
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
