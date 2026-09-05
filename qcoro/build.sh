#!/bin/bash
set -e
name=qcoro
repo="danvratil/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(qt6)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/danvratil/qcoro/archive/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/opt/qt6 \
      -D CMAKE_BUILD_TYPE=Release     \
      -D BUILD_TESTING=OFF            \
      -D QCORO_BUILD_EXAMPLES=OFF     \
      -D BUILD_SHARED_LIBS=ON)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
