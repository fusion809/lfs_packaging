#!/bin/bash
set -e
name=iso-codes
homepage="https://salsa.debian.org/iso-codes-team/iso-codes"
description="Lists of the country, language, and currency names"
repo=iso-codes-team/$name
version=$(sd_ver $repo)
filename="$name-v$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://salsa.debian.org/iso-codes-team/iso-codes/-/archive/v$version/$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
