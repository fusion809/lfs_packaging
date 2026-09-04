#!/bin/bash
set -e
name=graphviz
repo=$name/$name
version=$(gl_ver $repo)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
depends=(cmake pango cairo xorg-libs fontconfig libpng)
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.com/graphviz/graphviz/-/archive/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
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
