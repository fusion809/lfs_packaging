#!/bin/bash
set -e
name=graphviz
homepage="https://www.graphviz.org"
repo=$name/$name
version=$(gl_ver $repo)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
depends=(cairo cmake fontconfig libpng pango xorg-libs)
gla_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
sed '/ORIGIN/d' -i lib/CMakeLists.txt
mkdir -p build &&
cd    build &&

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      ..                           &&

sed -i '/GZIP/s/:.*$/=/' CMakeCache.txt &&

make -j$(nproc)
sudo make install
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
