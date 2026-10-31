#!/bin/bash
set -e
name=libebur128
repo=jiixyj/$name
homepage="https://github.com/jiixyj/libebur128"
description="Implements EBU R128 standard for loudness normalization."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DBUILD_STATIC_LIBS=OFF \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
