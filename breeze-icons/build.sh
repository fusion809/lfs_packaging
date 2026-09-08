#!/bin/bash
set -e
name=breeze-icons
repo=KDE/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 dbus double-conversion elfutils expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu libX11 libXau libXdmcp libXext libXxf86vm libffi libpciaccess libpng libxcb libxkbcommon libxml2 libxshmfence mesa pcre2 qt6 systemd wayland xz zlib zstd)
blfs_depends=(libdrm llvm lm-sensors spirv-tools)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.kde.org/stable/frameworks/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr \
      -D BUILD_TESTING=OFF         \
      -D WITH_ICON_GENERATION=OFF  \
      -W no-author)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
