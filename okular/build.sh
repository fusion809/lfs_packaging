#!/bin/bash
set -e
name=okular
repo=KDE/$name
homepage="https://invent.kde.org/graphics/okular"
description="Advanced document viewer for KDE."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
export SKIP_OPTIONAL='Discount;DjVuLibre;EPub;LibSpectre;LibZip'
cmake_options=(
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_BUILD_TYPE=Release         \
	-D BUILD_TESTING=OFF                \
	-D FORCE_NOT_REQUIRED_DEPENDENCIES="$SKIP_OPTIONAL" \
	-W no-author)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
