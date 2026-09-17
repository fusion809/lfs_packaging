#!/bin/bash
set -e
name=tiff
repo=lib$name/lib$name
version=$(gl_ver $repo)
depends=(bzip2 elfutils expat freeglut gcc glibc icu libdrm libffi libICE libjpeg-turbo libpciaccess libSM libwebp libX11 libXau libxcb libXdmcp libXext libXi libxml2 libXmu libXrandr libXrender libxshmfence libXt libXxf86vm llvm lm-sensors mesa spirv-tools util-linux xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.osgeo.org/libtiff/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -W no-author -G Ninja)
cmaki "${options[@]}"
sudo rm -rf /usr/share/doc/$direname
sudo mv -v /usr/share/doc/tiff{,-$version}
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
