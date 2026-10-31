#!/bin/bash
set -e
name=sdl_image
_name=SDL_image
repo=libsdl-org/$_name
homepage="https://github.com/libsdl-org/SDL_image"
description="Simple library to load images of various formats as SDL surfaces."
version=$(aver $name)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(libjpeg-turbo libpng tiff sdl12-compat zlib)
download_src "https://www.libsdl.org/projects/SDL_image/release/$filename"
unpk_enter "$filename" "$direname"
sudo su -c "export AUTOMAKE='automake --foreign'
autoreconf --force --install"
sudo chown $USER -R .
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
