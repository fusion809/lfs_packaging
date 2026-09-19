#!/bin/bash
set -e
source $HOME/lfs_packaging/shared-funcs.sh
name=libarchive
repo=$name/$name
version=$(gh_ver $repo)
direname="$name-$version"
filename="$direname.tar.xz"
depends=(acl bzip2 coreutils gcc glibc libxml2 lz4 make openssl tar wget xz zlib zstd)
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
sudo install -Dm755 ../unzip /usr/bin/
cd ..
rm -rf $direname $filename
echo "$version" | sudo tee /var/lib/custom-packages/$name
