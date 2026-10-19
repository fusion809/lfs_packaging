#!/bin/bash
set -e
name=wxwidgets-gtk3
_name=wxWidgets
repo=$_name/$_name
homepage="https://wxwidgets.org"
description="GTK+3 implementation of wxWidgets API GUI."
version=$(gh_ver $repo)
depends=(cmake git glu gst-plugins-base libmspack libnotify nanosvg webkitgtk)
download_git "https://github.com/wxWidgets/wxWidgets"
cd $_name
cmake_options=(
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_BUILD_TYPE=None \
	-DwxBUILD_TOOLKIT=gtk3 \
	-DwxUSE_OPENGL=ON \
        -DwxUSE_REGEX=sys \
        -DwxUSE_ZLIB=sys \
        -DwxUSE_EXPAT=sys \
        -DwxUSE_LIBJPEG=sys \
        -DwxUSE_LIBPNG=sys \
        -DwxUSE_LIBTIFF=sys \
        -DwxUSE_LIBLZMA=sys \
        -DwxUSE_NANOSVG=sys \
        -DwxUSE_LIBMSPACK=ON \
        -DwxUSE_PRIVATE_FONTS=ON \
        -DwxUSE_GTKPRINT=ON \
        -DwxUSE_HOTKEY=ON)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf $_name/build10
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
