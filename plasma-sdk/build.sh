#!/bin/bash
set -e
name=plasma-sdk
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr breeze-icons brotli bzip2 dbus double-conversion e2fsprogs expat flac fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kauth kcodecs kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash kdbusaddons keyutils kglobalaccel kguiaddons ki18n ki18n kiconthemes kio kirigami kitemviews kjobwidgets knotifications kpackage kparts kservice ksvg ktexteditor kwidgetsaddons kwindowsystem kxmlgui lame libcanberra libdrm libelf libffi libICE libogg libpciaccess libplasma libpng libSM libsndfile libvorbis libX11 libXau libxcb libXdmcp libXext libXfixes libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa mitkrb mpg123 openssl opus pcre2 plasma5support plasma-activities pulseaudio qt6 solid sonnet spirv-tools syntax-highlighting systemd util-linux wayland webkitgtk xcb-util-keysyms xz zlib zstd)
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
