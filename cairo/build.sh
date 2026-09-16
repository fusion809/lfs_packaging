#!/bin/bash
set -e
name=cairo
repo=$name/$name
version=$(gfd_ver $repo)
depends=(brotli bzip2 expat fontconfig freetype glib2 glibc libffi libpng libX11 libXau libxcb libXdmcp libXext libXrender pcre2 pixman zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://www.cairographics.org/releases/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr \
	--buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
