#!/bin/bash
set -e
name=plasma-integration
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr breeze-icons brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kbookmarks kcodecs kcolorscheme kcompletion kconfig kcoreaddons kcrash keyutils kguiaddons ki18n kiconthemes kio kitemviews kjobwidgets knotifications kservice kstatusnotifieritem kwidgetsaddons kwindowsystem libcanberra libdrm libelf libffi libogg libpciaccess libpng libvorbis libX11 libXau libxcb libXcursor libXdmcp libXext libXfixes libxkbcommon libxml2 libXrender libxshmfence libXxf86vm llvm lm-sensors mesa mitkrb openssl pcre2 qt6 solid spirv-tools systemd util-linux wayland webkitgtk xcb-util-keysyms xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
export PATH=$PATH:/opt/qt6/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/qt6/lib
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
