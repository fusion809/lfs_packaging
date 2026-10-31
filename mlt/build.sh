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
sed -i '/^add_library(GlaxnimatePythonEmbed OBJECT/a set_source_files_properties(${SOURCES} embed.cpp PROPERTIES COMPILE_OPTIONS "-Wno-error=undef")' src/plugin/python/CMakeLists.txt
sed -i '/^configure_file(resources\/glaxnimate.in.qrc/i set_source_files_properties(gui_python/gui_python.cpp gui_python/python_engine.cpp PROPERTIES COMPILE_OPTIONS "-Wno-error=undef")' src/gui/CMakeLists.txt
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DMOD_OPENCV=ON \
    -DMOD_GLAXNIMATE_QT6=ON \
    -DMOD_QT6=ON \
    -DSWIG_PYTHON=ON)
if [[ -d build ]]; then
	rm -rf build
fi
cmaki "${cmake_options[@]}"
cd ..
rm -rf build
cd ..
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
