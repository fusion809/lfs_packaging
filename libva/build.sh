#!/bin/bash
set -e
name=libva
repo=intel/$name
version=$(gh_ver $repo)
depends=(bzip2 elfutils expat gcc glibc icu libX11 libXau libXdmcp libXext libXfixes libXxf86vm libdrm libffi libpciaccess libxcb libxml2 libxshmfence lm-sensors mesa spirv-tools wayland xz zlib zstd)
blfs_depends=(llvm)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/archive/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
