#!/bin/bash
name=yyjson
version=$(gh_ver ibireme/yyjson)
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
cmake_options=(
	-DCMAKE_BUILD_TYPE='None' \
	-DCMAKE_INSTALL_PREFIX='/usr' \
	-DBUILD_SHARED_LIBS='ON' \
	-DYYJSON_BUILD_TESTS='ON' \
	-Wno-dev
)
cmaki "${cmake_options[@]}"
cd ..
sudo mkdir -p /usr/share/doc/$direname
sudo install -Dm644 README.md /usr/share/doc/$direname
sudo install -Dm644 doc/*.md /usr/share/doc/$direname
# Cleanup and add to database
cd ..
rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name