#!/bin/bash
set -e
name=sdl3
repo=libsdl-org/SDL
version=$(gh_ver $repo)
depends=(glibc)
filename="SDL3-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.libsdl.org/release/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
gap_patches $name
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr       -D CMAKE_BUILD_TYPE=Release -D SDL_TEST_LIBRARY=OFF      \
      -D SDL_STATIC=OFF            \
      -D SDL_RPATH=OFF             \
      -W no-author -G Ninja)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
