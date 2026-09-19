#!/bin/bash
set -e
name=tiff
repo=lib$name/lib$name
version=$(gl_ver $repo)
depends=(bzip2 elfutils expat freeglut gcc glibc icu libdrm libffi libICE libjpeg-turbo libpciaccess libSM libwebp libX11 libXau libxcb libXdmcp libXext libXi libxml2 libXmu libXrandr libXrender libxshmfence libXt libXxf86vm llvm lm-sensors mesa spirv-tools util-linux xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://download.osgeo.org/libtiff/$filename"
unpk_enter "$filename" "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -W no-author -G Ninja)
cmaki "${options[@]}"
sudo rm -rf /usr/share/doc/$direname
sudo mv -v /usr/share/doc/tiff{,-$version}
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
