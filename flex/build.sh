#!/bin/bash
set -e
name=flex
repo="westes/flex"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
lfs_depends=(glibc make gcc gzip tar coreutils)
if ! [[ -f "${filename}" ]]; then
    wget -c https://github.com/$repo/releases/download/v${version}/${filename} -O $filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi "--prefix=/usr --disable-static --docdir=/usr/share/doc/$direname"
sudo su -c "ln -sv flex   /usr/bin/lex
ln -sv flex.1 /usr/share/man/man1/lex.1"
cd ..
rm -rf "$filename" "$direname"
echo "$version" > /var/lib/custom-packages/$name
