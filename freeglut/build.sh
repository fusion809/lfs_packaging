#!/bin/bash
set -e
name=freeglut
repo=$name/$name
version=$(gh_ver $repo)
depends=(bzip2 expat gcc glibc icu libX11 libXext libXi libXrandr libXrender libXxf86vm libffi libpciaccess libxml2 libxshmfence mesa xz zlib zstd)
blfs_depends=(libXau libXdmcp libdrm libxcb llvm lm-sensors spirv-tools)
lfs_depends=(libelf)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://downloads.sourceforge.net/freeglut/$filename
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
