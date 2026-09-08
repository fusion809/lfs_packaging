#!/bin/bash
set -e
name=openjpeg
repo=uclouvain/$name
version=$(gh_ver $repo)
depends=(glibc libpng xz zlib zstd cmake)
blfs_depends=(lcms2 libjpeg-turbo libtiff libwebp)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(-D CMAKE_BUILD_TYPE=Release  \
      -D CMAKE_INSTALL_PREFIX=/usr \
      -D BUILD_STATIC_LIBS=OFF)
cmaki "${options[@]}"
sudo cp -rv ../doc/man -T /usr/share/man
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
