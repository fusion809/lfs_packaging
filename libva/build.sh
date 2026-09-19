#!/bin/bash
set -e
name=libva
repo=intel/$name
version=$(gh_ver $repo)
depends=(bzip2 elfutils expat gcc glibc icu libdrm libffi libpciaccess libX11 libXau libxcb libXdmcp libXext libXfixes libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa spirv-tools wayland xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/archive/$version/$filename
fi
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
