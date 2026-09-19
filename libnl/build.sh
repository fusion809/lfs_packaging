#!/bin/bash
set -e
name=libnl
repo=thom311/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
# Kernel config options required
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/libnl$(echo $version | sed -E 's/\./_/g')/$filename
fi
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --sysconfdir=/etc --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
