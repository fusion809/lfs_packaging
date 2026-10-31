#!/bin/bash
set -e
name=krita
repo=KDE/$name
homepage="https://krita.org/"
description="Edit and paint images."
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(exiv2 ffmpeg fftw fontconfig freetype fribidi giflib glibc gsl harfbuzz imath kcolorscheme kcompletion kconfig kcoreaddons kcrash kguiaddons ki18n kitemviews kwidgetsaddons lcms2 gcc libjpeg-turbo libkdcraw libpng tiff libunibreak libwebp libx11 libxkbcommon mlt opencolorio openexr openjpeg2 qt6 quazip wayland zlib boost eigen extra-cmake-modules immer kseexpr lager libheif libjxl libmypaint poppler pyqt6 xsimd zug)
download_src "https://download.kde.org/stable/krita/$version/$filename"
unpk_enter "$filename" "$direname"
wget -c https://invent.kde.org/graphics/krita/-/commit/3f5b2882.patch
wget -c https://invent.kde.org/graphics/krita/-/commit/c8028b3e.patch
sed -e 's|13.0|13.8|' -i cmake/modules/SIPMacros.cmake # Update SIP ABI version
patch -Np1 -i 3f5b2882.patch
patch -Np1 -i c8028b3e.patch
cmake_options=(-DBUILD_KRITA_QT_DESIGNER_PLUGINS=ON \
    -DBUILD_TESTING=OFF \
    -DBUILD_WITH_QT6=ON \
    -DALLOW_UNSTABLE=QT6)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
