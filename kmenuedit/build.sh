#!/bin/bash
set -e
name=kmenuedit
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr breeze-icons brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kcodecs kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash kdbusaddons keyutils kglobalaccel kguiaddons ki18n kiconthemes kio kitemviews kjobwidgets knotifications kservice kwidgetsaddons kwindowsystem kxmlgui libcanberra libdrm libelf libffi libogg libpciaccess libpng libvorbis libX11 libXau libxcb libXdmcp libXext libXfixes libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa mitkrb openssl pcre2 qt6 solid sonnet spirv-tools systemd util-linux wayland webkitgtk xcb-util-keysyms xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
