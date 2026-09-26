#!/bin/bash
set -e
name=expat
homepage="https://libexpat.github.io/"
description="An XML parser library"
repo=libexpat/libexpat
version=$(gh_ver $repo)
_version=$(echo $version | sed 's/\./_/g')
filename="$name-$version.tar.xz"
direname="lib$name-R_${_version}"
depends=(coreutils gcc glibc make tar xz)
gha_download $repo "R_${_version}" "$filename"
unpk_enter "$filename" "$direname" "expat"
echo "pwd=$PWD"
options=(--prefix=/usr \
	--disable-static \
	--docdir=/usr/share/doc/$direname)
oldVer=$(pkgver $name)
if [[ $oldVer != $version ]]; then
	oldDir=expat
	sudo rm -rf /usr/lib/cmake/$oldDir
	sudo rm -rf /usr/share/doc/$oldDir
fi
cmaki -DCMAKE_INSTALL_PREFIX=/usr
cd ..
sudo mv /usr/share/doc/expat /usr/share/doc/$name-$version
sudo install -v -m644 doc/*.{html,css} /usr/share/doc/$name-$version
cd ../..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
