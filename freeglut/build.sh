#!/bin/bash
set -e
name=freeglut
repo=$name/$name
version=$(gh_ver $repo)
depends=(bzip2 expat gcc glibc icu libdrm libelf libffi libpciaccess libX11 libXau libxcb libXdmcp libXext libXi libxml2 libXrandr libXrender libxshmfence libXxf86vm llvm lm-sensors mesa spirv-tools xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://downloads.sourceforge.net/freeglut/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr       -D CMAKE_BUILD_TYPE=Release -D FREEGLUT_BUILD_DEMOS=OFF         \
      -D FREEGLUT_BUILD_STATIC_LIBS=OFF   \
      -W no-author)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
