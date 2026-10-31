#!/bin/bash
set -e
name=mlt
repo=mltframework/$name
homepage="https://www.mltframework.org/"
description="Open-source multimedia framework."
version=$(gh_ver $repo)
depends=(glibc libebur128 gcc eigen frei0r-plugins ffmpeg ladspa libexif libsamplerate lilv movit opencv rtaudio rubberband sdl_image vid.stab swig vulkan-headers)
download_git "https://github.com/$repo.git"
download_git "https://invent.kde.org/graphics/glaxnimate.git"
download_git "https://github.com/mbasaglia/thorvg.git"
srcdir=$PWD
cd $name
git checkout v$version
git submodule init
  git submodule set-url src/modules/glaxnimate/glaxnimate "$srcdir"/glaxnimate
  git -c protocol.file.allow=always submodule update

  cd src/modules/glaxnimate/glaxnimate
  git submodule init
  git submodule set-url external/thorvg/thorvg "$srcdir"/thorvg
  git -c protocol.file.allow=always submodule update external/thorvg/thorvg
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DMOD_OPENCV=ON \
    -DMOD_GLAXNIMATE_QT6=ON \
    -DMOD_QT6=ON \
    -DSWIG_PYTHON=ON)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
