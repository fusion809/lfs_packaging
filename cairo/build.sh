#!/bin/bash
set -e
name=cairo
repo=$name/$name
version=$(gfd_ver $repo)
depends=(brotli bzip2 expat fontconfig freetype glib2 glibc libffi libpng libx11 libxau libxcb libxdmcp libxext libxrender pcre2 pixman zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://www.cairographics.org/releases/$filename"
unpk_enter "$filename" "$direname"
options=(
	--prefix=/usr \
	--buildtype=release
)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
