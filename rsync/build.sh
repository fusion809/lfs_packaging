#!/bin/bash
set -e
name=rsync
repo=RsyncProject/$name
version=$(gh_ver $repo)
depends=(acl glibc lz4 openssl popt zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.samba.org/ftp/rsync/src/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr    \
            --disable-xxhash \
            --without-included-zlib
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
