#!/bin/bash
set -e
name=flex
repo="westes/flex"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(coreutils gcc glibc gzip make tar)
ghr_download "$repo" "v${version}" "${filename}"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static --docdir=/usr/share/doc/$direname
sudo su -c "ln -sf flex   /usr/bin/lex
ln -sf flex.1 /usr/share/man/man1/lex.1"
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee /var/lib/custom-packages/$name
