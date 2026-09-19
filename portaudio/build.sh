#!/bin/bash
set -e
# Variable declarations
name=portaudio
repo=$name/$name
version=$(gh_ver "$repo")
filename="$name-v$version.tar.gz"
direname=$(echo "${filename/.tar.gz/}" | sed 's/v//g')
depends=(alsa-lib autoconf bash cmake coreutils gcc glibc gzip jack make opus sed tar wget)
# Fetch and unpack source
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
configure_options=(
	--prefix=/usr \
	--enable-cxx
)
./configure "${configure_options[@]}"
make -j1
sudo make install
sudo mkdir /usr/share/doc/$direname/ -p
sudo install -Dm644 README.* /usr/share/doc/$direname/
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
