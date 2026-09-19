#!/bin/bash
set -e
name=kquickimageeditor
repo=KDE/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu kconfig keyutils libdrm libelf libffi libpciaccess libpng libX11 libXau libxcb libXdmcp libXext libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa mitkrb opencv openssl pcre2 qt6 spirv-tools systemd wayland xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
kde_download "other" "$filename"
unpk_enter "$filename" "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr       -D CMAKE_BUILD_TYPE=Release               -D BUILD_TESTING=OFF -W no-author)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
