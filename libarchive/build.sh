#!/bin/bash
set -e
source $HOME/lfs_packaging/shared-funcs.sh
name=libarchive
version=$(gh_ver "libarchive/libarchive")
direname="$name-$version"
filename="$direname.tar.xz"
depends=(acl bzip2 coreutils gcc glibc libxml2 lz4 make openssl tar wget xz zlib zstd)
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/libarchive/libarchive/releases/download/v$version/$filename
fi

unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
sudo install -Dm755 ../unzip /usr/bin/
cd ..
rm -rf $direname $filename
echo "$version" | sudo tee /var/lib/custom-packages/$name
