#!/bin/bash
name=yyjson
version=$(wget -cqO- https://github.com/ibireme/yyjson/releases | grep "/tag/[0-9]" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=()
lfs_depends=(bash coreutils glibc gzip tar)
blfs_depends=(cmake)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/ibireme/yyjson/archive/$version.tar.gz -O $filename
fi
rm -rf $direname
tar xvf $filename
# Compile and install
cd $direname
cmake -B build -S . \
	  -DCMAKE_BUILD_TYPE='None' \
	  -DCMAKE_INSTALL_PREFIX='/usr' \
	  -DBUILD_SHARED_LIBS='ON' \
	  -DYYJSON_BUILD_TESTS='ON' \
	  -Wno-dev
cmake --build build
sudo cmake --install build
sudo mkdir -p /usr/share/doc/$direname
sudo install -Dm644 README.md /usr/share/doc/$direname
sudo install -Dm644 doc/*.md /usr/share/doc/$direname
# Cleanup and add to database
cd ..
rm -rf $direname $filename
echo $version > /var/lib/lfs-custom-packages/$name