#!/bin/bash
set -e
name=breeze-icons
repo=KDE/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 dbus double-conversion elfutils expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu libdrm libffi libpciaccess libpng libx11 libxau libxcb libxdmcp libxext libxkbcommon libxml2 libxshmfence libxxf86vm llvm lm-sensors mesa pcre2 qt6 spirv-tools systemd wayland xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
kde_download "frameworks" "$filename"
unpk_enter "$filename" "$direname"
options=(
      -D CMAKE_INSTALL_PREFIX=/usr \
      -D BUILD_TESTING=OFF         \
      -D WITH_ICON_GENERATION=OFF  \
      -W no-author
)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
