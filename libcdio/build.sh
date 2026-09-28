#!/bin/bash
set -e
name=libcdio
homepage="https://www.gnu.org/software/libcdio/"
description="GNU Compact Disc Input and Control Library"
repo=libcdio/libcdio-C
#version=$(gnu_ver $name)
version=$(gh_ver $repo "$name")
pr_repo=libcdio/libcdio-paranoia
pr_version=$(gh_ver $pr_repo)
pr_filename="libcdio-paranoia-$pr_version.tar.bz2"
pr_direname="${pr_filename/.tar.*/}"
depends=(gcc glibc ncurses)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$version" "$filename"
ghr_download "$pr_repo" "$pr_version" "$pr_filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
tar -xf ../$pr_filename &&
cd $pr_direname &&
cmi --prefix=/usr --disable-static &&
cd ../..
rm -rf "$filename" "$direname" "$pr_filename"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
