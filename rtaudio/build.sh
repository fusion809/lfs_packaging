#!/bin/bash
set -e
name=rtaudio
repo=thestk/$name
homepage="https://github.com/thestk/rtaudio"
description="Set of C++ classes that provide a common API for realtime audio input/output."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
meson_options=(
    -D core=disabled
    -D dsound=disabled
    -D asio=disabled
    -D wasapi=disabled
    -D docs=false
    -D install_docs=false
    --prefix=/usr
  )
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
