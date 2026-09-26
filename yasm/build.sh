#!/bin/bash
set -e
name=yasm
homepage="https://github.com/yasm/yasm"
description="A rewrite of NASM to allow for multiple syntax supported (NASM, TASM, GAS, etc.)"
repo="$name/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://www.tortall.net/projects/yasm/releases/$filename"
unpk_enter "$filename" "$direname"
sed -e 's/def __cplusplus/ defined(__cplusplus) || __STDC_VERSION__ >= 202311L/' \
    -i libyasm/bitvect.h
sed -i 's#) ytasm.*#)#' Makefile.in
cmi --prefix=/usr
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
