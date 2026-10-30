#!/bin/bash
set -e
name=qwt
repo=$name/git
homepage="https://qwt.sourceforge.io/"
description="Qt widgets for technical applications"
version=$(sf_ver $repo)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
download_src "https://downloads.sourceforge.net/$name/$filename"
unpk_enter "$filename" "$direname"
sed -e '/^\s*QWT_INSTALL_PREFIX/ s|=.*|= /usr|' \
      -e '/^QWT_INSTALL_DOCS/ s|/doc|/share/doc/qwt|' \
      -e '/^QWT_INSTALL_HEADERS/ s|include|&/qwt|' \
      -e '/^QWT_INSTALL_PLUGINS/ s|plugins/designer|lib/qt6/&|' \
      -e '/^QWT_INSTALL_FEATURES/ s|features|lib/qt6/mkspecs/&|' \
      -i qwtconfig.pri
qmake qwt.pro
maki
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
