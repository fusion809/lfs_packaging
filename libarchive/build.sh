#!/bin/bash
set -e
source $HOME/lfs_packaging/shared-funcs.sh
name=libarchive
version=$(gh_ver "libarchive/libarchive")
direname="$name-$version"
filename="$direname.tar.xz"
lfs_depends=(acl bzip2 coreutils gcc glibc lz4 make openssl tar wget xz zlib zstd)
blfs_depends=(libxml2)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/libarchive/libarchive/releases/download/v$version/$filename
fi

rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --disable-static
sudo install -Dm755 ../unzip /usr/bin/
cd ..
rm -rf $direname $filename
echo "$version" > /var/lib/custom-packages/$name
