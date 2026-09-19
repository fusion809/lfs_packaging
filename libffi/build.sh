#!/bin/bash
set -e
name=libffi
repo=libffi/libffi
version=$(gh_ver $repo)
depends=(coreutils gcc glibc gzip make tar)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
    wget -c --progress=bar:force https://github.com/$repo/releases/download/v$version/$filename
fi
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static --with-gcc-arch=native
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
