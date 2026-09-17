#!/bin/bash
set -e
name=smartmontools
repo=$name/$name
version=$(gh_ver $repo)
depends=(gcc glibc systemd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
sf_download "$name" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --sysconfdir=/etc --docdir=/usr/share/doc/$direname
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
