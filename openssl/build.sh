#!/bin/bash
set -e
name=openssl
repo=${name}/$name
version=$(gh_ver $repo)
lfs_depends=(bash brotli glibc zlib zstd gzip tar coreutils)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
    wget -c https://github.com/$repo/releases/download/$direname/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
make -j$(nproc)
sudo make INSTALL_LIBS= MANSUFFIX=ssl install
sudo mv -v /usr/share/doc/openssl /usr/share/doc/$direname
sudo cp -vfr doc/* /usr/share/doc/$direname
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
