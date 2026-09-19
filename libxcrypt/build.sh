#!/bin/bash
set -e
name=libxcrypt
repo=besser82/$name
version=$(gh_ver $repo)
depends=(coreutils gcc glibc gzip make sed tar)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
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
echo "$version" | sudo tee /var/lib/custom-packages/$name
