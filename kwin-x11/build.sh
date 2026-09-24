#!/bin/bash
set -e
name=kwin-x11
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attica attr breeze-icons brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kauth kcmutils kcodecs kcolorscheme kconfig kconfigwidgets kcoreaddons kcrash kdecoration keyutils kglobalaccel kglobalacceld kguiaddons kholidays ki18n kiconthemes kidletime kio kitemviews kjobwidgets knewstuff knighttime knotifications kpackage kscreenlocker kservice ksvg kwidgetsaddons kwindowsystem kxmlgui lcms2 libcanberra libdisplay-info libdrm libelf libepoxy libffi libice libogg libpciaccess libpng libSM libvorbis libX11 libxau libxcb libXdmcp libXext libXfixes libXi libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa mitkrb openssl pcre2 plasma-activities qt6 solid spirv-tools syndication systemd util-linux wayland webkitgtk xcb-util xcb-util-cursor xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
