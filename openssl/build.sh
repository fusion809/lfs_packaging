#!/bin/bash
set -e
name=openssl
repo=${name}/$name
version=$(gh_ver $repo)
depends=(bash brotli coreutils glibc gzip tar zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
    wget -c --progress=bar:force https://github.com/$repo/releases/download/$direname/$filename
fi
unpk_enter "$filename" "$direname"
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
echo "$version" | sudo tee /var/lib/custom-packages/$name
