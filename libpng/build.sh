#!/bin/bash
set -e
name=libpng
description="Collection of routines used to create PNG format graphics files."
homepage="https://www.libpng.org/pub/png/libpng.html"
repo=pnggroup/libpng
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
patch_filename="$name-$version-apng.patch.gz"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
patch_url=$(wget -T 5 -t 1 -cqO- https://www.linuxfromscratch.org/blfs/view/systemd/general/libpng.html | grep ".patch.gz" | cut -d '"' -f 2 | head -n 1)
patch_filename=$(echo $patch_url | rev | cut -d '/' -f 1 | rev)
download_src "$patch_url" && zcat $patch_filename | patch -p1 || echo "Patch failed. So animated features may not work."
cmi --prefix=/usr --disable-static
sudo install -vDm644 README libpng-manual.txt -t /usr/share/doc/$direname
cd ..
rm -rf "$filename" "$direname" "$patch_filename"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
