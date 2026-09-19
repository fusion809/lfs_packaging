#!/bin/bash
set -e
name=cryptsetup
repo=mbroz/$name
version=$(gh_ver $repo)
majMinVer=$(echo $version | cut -d '.' -f1-2)
depends=(glibc json-c lvm2 openssl popt systemd util-linux)
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
