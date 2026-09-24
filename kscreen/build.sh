#!/bin/bash
set -e
name=kscreen
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr breeze-icons brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kcmutils kcodecs kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash kdbusaddons keyutils kglobalaccel kguiaddons ki18n kiconthemes kio kirigami kitemviews kjobwidgets knotifications kpackage kservice ksvg kwidgetsaddons kwindowsystem kxmlgui layer-shell-qt libcanberra libdrm libelf libffi libice libogg libpciaccess libplasma libpng libSM libsndfile libvorbis libx11 libxau libxcb libxdmcp libxext libxfixes libxi libxkbcommon libxml2 libxshmfence libxxf86vm llvm lm-sensors mesa mitkrb openssl pcre2 plasma-activities qt6 solid spirv-tools systemd util-linux wayland webkitgtk xcb-util xcb-util-keysyms xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
