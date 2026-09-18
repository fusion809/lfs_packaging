#!/bin/bash
set -e
name=aurorae
repo=KDE/$name
version=$(gh_ver $repo)
depends=(breeze-icons brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kcmutils kcodecs kcolorscheme kconfig kconfigwidgets kcoreaddons kdecoration keyutils kglobalaccel kguiaddons ki18n kiconthemes kitemviews kpackage ksvg kwidgetsaddons kxmlgui libdrm libelf libffi libpciaccess libpng libX11 libXau libxcb libXdmcp libXext libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa mitkrb openssl pcre2 qt6 spirv-tools systemd util-linux wayland xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
