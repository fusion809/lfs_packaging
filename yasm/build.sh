#!/bin/bash
set -e
name=yasm
repo="$name/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.tortall.net/projects/yasm/releases/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
sed -e 's/def __cplusplus/ defined(__cplusplus) || __STDC_VERSION__ >= 202311L/' \
    -i libyasm/bitvect.h
sed -i 's#) ytasm.*#)#' Makefile.in
cmi --prefix=/usr
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
