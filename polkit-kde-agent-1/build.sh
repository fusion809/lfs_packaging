#!/bin/bash
set -e
name=polkit-kde-agent-1
homepage="https://kde.org/plasma-desktop/"
description="Daemon providing a polkit authentication UI for KDE."
repo=KDE/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu kconfig kcoreaddons kcrash kdbusaddons keyutils ki18n knotifications kwindowsystem libcanberra libffi libglvnd libogg libpng libtool libvorbis libx11 libxau libxcb libxdmcp libxfixes libxkbcommon mitkrb openssl pcre2 polkit polkit-qt-1 qt6 systemd util-linux xcb-util-keysyms zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
