#!/bin/bash
set -e
name=avogadroapp
repo=OpenChemistry/$name
homepage="https://two.avogadro.cc"
description="An advanced molecular editor."
depends=(acl avogadrolibs brotli bzip2 cmake dbus double-conversion e2fsprogs eigen expat fast_float fmt fontconfig freetype gcc glew glib2 glibc graphite2 harfbuzz hdf5 hicolor-icon-theme icu jkqtplotter keyutils libaec libarchive libglvnd libpng libx11 libxau libxcb libxdmcp libxkbcommon libxml2 lz4 mitkrb nlohmann-json openssl pcre2 pugixml qt6 spglib systemd utf8cpp vtk xz zlib zstd)
pip_depends=(cclib)
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DUSE_VTK=ON)
cmaki "${cmake_options[@]}"
# Fix desktop config icon issue; without Avogadro2 doesn't have an icon shown in app menus
# under WhiteSur icon theme
sudo cp /usr/share/icons/hicolor/32x32/apps/org.openchemistry.Avogadro2.png /usr/share/pixmaps
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
