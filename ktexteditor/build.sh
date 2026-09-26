#!/bin/bash
set -e
name=ktexteditor
homepage="https://develop.kde.org/products/frameworks/"
description="Advanced embeddable text editor"
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr breeze-icons brotli bzip2 dbus double-conversion e2fsprogs expat flac fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kauth kcodecs kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash keyutils kglobalaccel kguiaddons ki18n kiconthemes kio kitemviews kjobwidgets knotifications kparts kservice kwidgetsaddons kwindowsystem kxmlgui lame libcanberra libdrm libelf libffi libogg libpciaccess libpng libsndfile libvorbis libx11 libxau libxcb libxdmcp libxext libxfixes libxkbcommon libxml2 libxshmfence libxxf86vm llvm lm-sensors mesa mitkrb mpg123 openssl opus pcre2 pulseaudio qt6 solid sonnet spirv-tools syntax-highlighting systemd util-linux wayland webkitgtk xcb-util-keysyms xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
kde_download "frameworks" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr \
            -D CMAKE_INSTALL_LIBEXECDIR=libexec \
            -D CMAKE_PREFIX_PATH=/opt/qt6        \
            -D CMAKE_SKIP_INSTALL_RPATH=ON      \
            -D CMAKE_BUILD_TYPE=Release         \
            -D BUILD_TESTING=OFF                \
            -D BUILD_PYTHON_BINDINGS=OFF        \
	    -W no-author)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
