#!/bin/bash
set -e
name=json-c
version=$(gh_ver $name/$name | sed -E 's/[.-][0-9]+$//g')
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake)
if ! [[ -f $filename ]]; then
	wget -c https://s3.amazonaws.com/json-c_releases/releases/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D BUILD_STATIC_LIBS=OFF)
cmaki "${cmake_options[@]}"
cd ..
sudo su -c "install -d -vm755 /usr/share/doc/$direname &&
install -v -m644 doc/html/* /usr/share/doc/$direname"
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
