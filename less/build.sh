#!/bin/bash
set -e
name=less
description="Terminal based program for viewing text files."
homepage="https://gnu.org/s/less/"
repo="gwsw/less"
version=$(gh_ver $repo || wgnu_ver "$name")
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(glibc ncurses pcre2)
#download_src "https://www.greenwoodsoftware.com/less/$filename"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
sudo autoreconf -fiv
sudo chown $USER -R .
./configure --prefix=/usr --disable-static
make -f Makefile.aut
make -j$(nproc)
make -f Makefile.aut less.nro
make -f Makefile.aut lesskey.nro
make -f Makefile.aut lessecho.nro
sudo make install
cd ..
rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
