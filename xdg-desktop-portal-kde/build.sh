#!/bin/bash
set -e
name=xdg-desktop-portal-kde
homepage="https://kde.org/plasma-desktop/"
description="Backend implementation for xdg-desktop-portal using Qt/KF5."
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr breeze-icons brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kbookmarks kcodecs kcolorscheme kcompletion kconfig kcoreaddons kcrash keyutils kglobalaccel kguiaddons ki18n kiconthemes kio kitemviews kjobwidgets knotifications kservice kstatusnotifieritem kwayland kwidgetsaddons kwindowsystem libcanberra libdrm libelf libffi libglvnd libice libogg libpciaccess libpng libsm libtool libvorbis libx11 libxau libxcb libxdmcp libxext libxfixes libxkbcommon libxml2 libxmu libxshmfence libxt libxxf86vm llvm lm-sensors mesa mitkrb numactl openssl pcre2 qt6 solid spirv-tools systemd util-linux wayland webkitgtk x265 xcb-util-keysyms xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
