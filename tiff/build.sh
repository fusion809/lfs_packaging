#!/bin/bash
set -e
name=tiff
repo=lib$name/lib$name
version=$(gl_ver $repo)
depends=(bzip2 elfutils expat freeglut gcc glibc icu libICE libSM libX11 libXau libXdmcp libXext libXi libXmu libXrandr libXrender libXt libXxf86vm libffi libjpeg-turbo libpciaccess libxcb libxml2 libxshmfence mesa util-linux xz zlib zstd)
blfs_depends=(libdrm libwebp llvm lm-sensors spirv-tools)
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
sudo mv -v /usr/share/doc/tiff{,-$version}
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
