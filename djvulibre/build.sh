#!/bin/bash
set -e
name=djvulibre
repo=djvu/$name-git
homepage="https://sourceforge.net/p/djvu/djvulibre-git/ci/master/tree/"
description="Open-source implementation of DjVu."
version=$(gsf_ver $repo)
depends=(gcc glibc libjpeg-turbo libwebp tiff xz zlib zstd)
direname="djvulibre-git"
download_git "https://git.code.sf.net/p/djvu/djvulibre-git" "$direname"
cd $direname
git checkout release.$version
cmi --prefix=/usr --disable-static --sysconfdir=/etc --localstatedir=/var
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
