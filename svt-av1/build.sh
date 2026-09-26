#!/bin/bash
set -e
name=svt-av1
homepage="https://gitlab.com/AOMediaCodec/SVT-AV1"
description="Scalable Video Technology AV1 encoder and decoder"
repo=AOMediaCodec/SVT-AV1
version=$(gl_ver $repo | sed 's/-cqp-extended//g')
depends=(gcc glibc)
filename="SVT-AV1-v$version.tar.gz"
direname="${filename/.tar.*/}"
gla_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr   \
      -D CMAKE_BUILD_TYPE=Release    \
      -D CMAKE_SKIP_INSTALL_RPATH=ON \
      -D BUILD_SHARED_LIBS=ON        \
      -W no-author -G Ninja)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
