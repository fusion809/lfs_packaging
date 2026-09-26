#!/bin/bash
set -e
name=rsync
homepage="https://rsync.samba.org/"
description="A fast and versatile file copying tool for remote and local files"
repo=RsyncProject/$name
version=$(gh_ver $repo)
depends=(acl glibc lz4 openssl popt zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://www.samba.org/ftp/rsync/src/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr    \
            --disable-xxhash \
            --without-included-zlib
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
