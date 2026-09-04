#!/bin/bash
set -e
name=libheif
repo="strukturag/$name"
version=$(gh_ver $repo)
blfs_depends=(libaom libde265 x265)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/strukturag/libheif/releases/download/v$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D WITH_GDK_PIXBUF=OFF       \
      -D WITH_OpenH264_DECODER=OFF \
      -G Ninja)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
