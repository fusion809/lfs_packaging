#!/bin/bash
set -e
name=drkonqi
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu kconfig kcoreaddons kcrash keyutils ki18n kidletime kio kjobwidgets knotifications kservice kstatusnotifieritem kwallet kwidgetsaddons kwindowsystem libcanberra libdrm libelf libffi libogg libpciaccess libpng libvorbis libx11 libxau libxcb libxdmcp libxext libxfixes libxkbcommon libxml2 libxshmfence libxxf86vm llvm lm-sensors mesa mitkrb openssl pcre2 polkit polkit-qt qt6 solid spirv-tools syntax-highlighting systemd util-linux wayland webkitgtk xcb-util-keysyms xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
