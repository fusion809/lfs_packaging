#!/bin/bash
set -e
name=plasma5support
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr breeze-icons brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kauth kbookmarks kcodecs kcolorscheme kcompletion kconfig kcoreaddons kcrash keyutils kguiaddons kholidays ki18n kiconthemes kidletime kio kitemviews kjobwidgets knotifications kservice kunitconversion kwidgetsaddons kwindowsystem libcanberra libdrm libelf libffi libksysguard libogg libpciaccess libpng libvorbis libx11 libxau libxcb libXdmcp libXext libXfixes libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa mitkrb networkmanager networkmanager-qt nspr nss openssl pcre2 plasma-activities qt6 solid spirv-tools systemd util-linux wayland webkitgtk xcb-util-keysyms xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
