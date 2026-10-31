#!/bin/bash
set -e
name=rubberband
repo=breakfastquay/$name
homepage="https://www.breakfastquay.com/rubberband/"
description="Time-stretching and pitch-shifting audio library and utility."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(java boost fftw ladspa libsamplerate libsndfile lv2 meson vamp-plugin-sdk)
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
meson_options=(-Dfft=fftw
    -Dresampler=libsamplerate
    -Dextra_include_dirs="/opt/jdk/include"
    --prefix=/usr)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
