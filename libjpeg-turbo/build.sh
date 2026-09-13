#!/bin/bash
set -e
name=libjpeg-turbo
repo=$name/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr        \
      -D CMAKE_BUILD_TYPE=RELEASE         \
      -D ENABLE_STATIC=FALSE              \
      -D CMAKE_INSTALL_DEFAULT_LIBDIR=lib \
      -D CMAKE_SKIP_INSTALL_RPATH=ON      \
      -D CMAKE_INSTALL_DOCDIR=/usr/share/doc/$direname)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
