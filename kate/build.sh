#!/bin/bash
set -e
name=kate
version=$(kap_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
blfs_depends=(frameworks6)
if ! [[ -f $filename ]]; then
	wget -c https://download.kde.org/stable/release-service/$version/src/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr  \
      -D CMAKE_BUILD_TYPE=Release          \
      -D BUILD_TESTING=OFF                 \
      -W no-author)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
