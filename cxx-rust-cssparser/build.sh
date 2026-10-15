#!/bin/bash
set -e
name=cxx-rust-cssparser
repo=KDE/$name
homepage="https://invent.kde.org/libraries/cxx-rust-cssparser"
description="Library for parsing CSS using the Rust cssparser crate."
version=$(gh_ver $repo)
depends=(acl attr brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu kconfig kcoreaddons kcrash kdbusaddons keyutils kguiaddons ki18n kidletime kio kjobwidgets knotifications kservice kstatusnotifieritem kwallet kwidgetsaddons kwindowsystem libcanberra libffi libglvnd libogg libpng libselinux libtool libvorbis libx11 libxau libxcb libxdmcp libxfixes libxkbcommon mitkrb openssl pcre2 polkit polkit-qt-1 qt6 solid syntax-highlighting systemd util-linux wayland xcb-util-keysyms zlib zstd)
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
