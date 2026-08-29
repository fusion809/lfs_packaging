#!/bin/bash
set -e
name=libxcrypt
repo=besser82/$name
version=$(gh_ver $repo)
lfs_depends=(glibc gcc make gzip sed tar coreutils)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
    wget -c https://github.com/$repo/releases/download/v$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
sed -i '/strchr/s/const//' lib/crypt-{sm3,gost}-yescrypt.c
configure_options=(
    --prefix=/usr                \
    --enable-hashes=strong,glibc \
    --enable-obsolete-api=no     \
    --disable-static             \
    --disable-failure-tokens
)
cmi "${configure_options[@]}"
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
