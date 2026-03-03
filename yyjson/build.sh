#!/bin/bash
NAME=yyjson
VERSION=$(wget -cqO- https://github.com/ibireme/yyjson/releases | grep "/tag/[0-9]" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6)
filename="$NAME-$VERSION.tar.gz"
direname="${filename/.tar.gz/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/ibireme/yyjson/archive/$VERSION.tar.gz -O $filename
fi
rm -rf $direname
tar xvf $filename
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
cd ..
rm -rf $direname $filename
echo $VERSION > /var/lib/lfs-custom-packages/$NAME