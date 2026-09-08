#!/bin/bash
set -e
name=svt-av1
repo=AOMediaCodec/SVT-AV1
version=$(gl_ver $repo)
depends=(gcc glibc)
filename="SVT-AV1-v$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.com/$repo/-/archive/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr   \
      -D CMAKE_BUILD_TYPE=Release    \
      -D CMAKE_SKIP_INSTALL_RPATH=ON \
      -D BUILD_SHARED_LIBS=ON        \
      -W no-author -G Ninja)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
