#!/bin/bash
set -e
name=jpegoptim
version=$(gh_ver "tjko/jpegoptim")
filename="$name-$version.tar.gz"
direname="$name-$version"
depends=(glibc libjpeg libjpeg-turbo)

if ! [[ -f "$filename" ]]; then
	wget -c --progress=bar:force https://github.com/tjko/jpegoptim/releases/download/v$version/$filename
fi

rm -rf $direname
tar xf $filename
cd $direname
./configure --prefix=/usr
make -j$(nproc)
make strip -j$(nproc)
sudo make install
cd ..
rm -rf $direname $filename
echo "$version" | sudo tee /var/lib/custom-packages/$name
