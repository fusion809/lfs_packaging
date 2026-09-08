#!/bin/bash
set -e
name=libwebp
repo=webmproject/$name
version=$(gh_ver $repo)
depends=(bzip2 elfutils expat freeglut gcc giflib glibc icu libX11 libXau libXdmcp libXext libXi libXrandr libXrender libXxf86vm libffi libjpeg-turbo libpciaccess libpng libxcb libxml2 libxshmfence mesa tiff xz zlib zstd)
blfs_depends=(libdrm llvm lm-sensors spirv-tools)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://storage.googleapis.com/downloads.webmproject.org/releases/webp/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr           \
            --enable-libwebpmux     \
            --enable-libwebpdemux   \
            --enable-libwebpdecoder \
            --enable-libwebpextras  \
            --enable-swap-16bit-csp \
	    --disable-static)
cmi "${options[@]}"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
