#!/bin/bash
set -e
name=expat
repo="libexpat/libexpat"
version=$(gh_ver $repo)
_version=$(echo $version | sed 's/\./_/g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
depends=(coreutils gcc glibc make tar xz)
if ! [[ -f $filename ]]; then
    wget -c --progress=bar:force https://github.com/libexpat/libexpat/releases/download/R_${_version}/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
options=(--prefix=/usr \
	--disable-static \
	--docdir=/usr/share/doc/$direname)
cmi "${options[@]}"
sudo install -v -m644 doc/*.{html,css} /usr/share/doc/$direname
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
