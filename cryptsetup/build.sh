#!/bin/bash
set -e
name=cryptsetup
homepage="https://gitlab.com/cryptsetup/cryptsetup/"
description="Setup tool for transparent encryption of block devices using dm-crypt."
repo=mbroz/$name
version=$(gh_ver $repo)
majMinVer=$(echo $version | cut -d '.' -f1-2)
depends=(gcc glibc json-c libselinux lvm2 openssl pcre2 popt systemd util-linux)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
# Kernel options required
download_src "https://www.kernel.org/pub/linux/utils/cryptsetup/v$majMinVer/$filename"
unpk_enter "$filename" "$direname"
options=(
    --prefix=/usr       
    --disable-ssh-token 
	--disable-asciidoc
)
cmi "${options[@]}"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
