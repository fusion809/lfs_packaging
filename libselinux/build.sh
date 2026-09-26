#!/bin/bash
set -e
name=libselinux
homepage="SELinux library and simple utilities"
description="SELinux library and simple utilities"
repo=SELinuxProject/selinux
version=$(gh_ver $repo)
depends=(gcc glibc libsepol pcre2)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
maki USE_LFS=y
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
