#!/bin/bash
set -e
name=plasma-desktop
homepage="https://kde.org/plasma-desktop/"
description="KDE Plasma Desktop"
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attica attr avahi baloo breeze-icons brotli bzip2 curl cyrus-sasl dbus double-conversion e2fsprogs expat flatpak fontconfig freetype gcc glib2 glibc gpgme graphite2 harfbuzz ibus icu json-glib karchive kauth kbookmarks kcmutils kcodecs kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash kdbusaddons keyutils kfilemetadata kglobalaccel kguiaddons ki18n kiconthemes kio kirigami kitemmodels kitemviews kjobwidgets knewstuff knotifications knotifyconfig kpackage krunner kservice ksvg kwidgetsaddons kwindowsystem kxmlgui libarchive libassuan libcanberra libdrm libelf libevdev libffi libgpg-error libgudev libice libidn2 libksysguard libogg libpciaccess libplasma libpng libpsl libseccomp libSM libsndfile libsoup libunistring libvorbis libwacom libx11 libxau libxcb libxcursor libxdmcp libxext libxfixes libxi libxkbcommon libxkbfile libxml2 libxrender libxshmfence libxxf86vm llvm lmdb lm-sensors lz4 mesa mitkrb nghttp2 openldap openssl ostree pcre2 plasma-activities plasma-activities-stats plasma-workspace polkit qt6 sdl2-compat solid sonnet spirv-tools sqlite syndication systemd util-linux wayland webkitgtk xcb-util xcb-util-cursor xcb-util-image xcb-util-keysyms xcb-util-renderutil xz zlib zstd)
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
