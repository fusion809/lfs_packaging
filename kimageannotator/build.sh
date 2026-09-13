#!/bin/bash
set -e
name=kimageannotator
repo=ksnip/kImageAnnotator
version=$(gh_ver $repo)
depends=(brotli bzip2 double-conversion expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu kcolorpicker libX11 libXext libXxf86vm libffi libpciaccess libpng libxkbcommon libxml2 libxshmfence mesa pcre2 systemd wayland xz zlib zstd)
blfs_depends=(libXau libXdmcp libdrm libxcb llvm lm-sensors qt6 spirv-tools)
lfs_depends=(dbus libelf)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr       -D CMAKE_BUILD_TYPE=Release -D BUILD_SHARED_LIBS=ON -D BUILD_WITH_QT6=ON)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
