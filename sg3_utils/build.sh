#!/bin/bash
set -e
name=sg3_utils
homepage="http://sg.danny.cz/sg/sg3_utils.html"
description="Generic SCSI utilities"
repo=doug-gilbert/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://sg.danny.cz/sg/p/$filename"
unpk_enter "$filename" "$direname"
sudo autoreconf -fiv
sudo chown $USER -R .
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
