#!/bin/bash
set -e
name=extra-cmake-modules
repo=KDE/$name
version=$(gh_ver $repo)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(cmake qt6)
kde_download "frameworks" "$version" "$filename"
unpk_enter "$filename" "$direname"
sed -i '/"lib64"/s/64//' kde-modules/KDEInstallDirsCommon.cmake &&

sed -e '/PACKAGE_INIT/i set(SAVE_PACKAGE_PREFIX_DIR "${PACKAGE_PREFIX_DIR}")' \
    -e '/^include/a set(PACKAGE_PREFIX_DIR "${SAVE_PACKAGE_PREFIX_DIR}")' \
    -i ECMConfig.cmake.in &&
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr \
      -D BUILD_WITH_QT6=ON         \
      -D DOC_INSTALL_DIR=/usr/share/doc/$direname)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
