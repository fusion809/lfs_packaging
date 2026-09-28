#!/bin/bash
set -e
name=less
description="A terminal based program for viewing text files."
homepage="https://gnu.org/s/less/"
repo="gwsw/less"
version=$(gh_ver $repo || wgnu_ver "$name")
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(glibc ncurses pcre2)
download_src "https://www.greenwoodsoftware.com/less/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --sysconfdir=/etc
cd ..
rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
