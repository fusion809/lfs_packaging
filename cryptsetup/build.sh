#!/bin/bash
set -e
name=cryptsetup
repo=mbroz/$name
version=$(gh_ver $repo)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
depends=(glibc json-c lvm2 openssl popt systemd util-linux)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
# Kernel options required
if ! [[ -f $filename ]]; then
	wget -c https://www.kernel.org/pub/linux/utils/cryptsetup/v$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr       \
            --disable-ssh-token \
	    --disable-asciidoc)
cmi "${options[@]}"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
