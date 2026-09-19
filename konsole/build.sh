#!/bin/bash
set -e
name=konsole
version=$(curl -sL https://download.kde.org/stable/release-service/ | perl -nle 'while (m{href="\K[0-9]+\.[0-9]+\.[0-9]+}g) { print $& }' | sort -V | tail -n 1)
depends=(acl attica attr breeze-icons brotli bzip2 dbus double-conversion e2fsprogs expat flac fontconfig freetype gcc glib2 glibc graphite2 harfbuzz karchive kbookmarks kcodecs kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash kdbusaddons keyutils kglobalaccel kguiaddons ki18n kiconthemes kio kitemviews kjobwidgets knewstuff knotifications knotifyconfig kpackage kparts kpty kservice ktextwidgets kwidgetsaddons kwindowsystem kxmlgui lame libcanberra libdrm libelf libffi libogg libpciaccess libpng libsndfile libssh libvorbis libX11 libXau libxcb libXdmcp libXext libXfixes libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors mitkrb mpg123 openssl opus pcre2 pulseaudio qt6 solid sonnet spirv-tools syndication systemd util-linux wayland webkitgtk xcb-util-keysyms xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
kde_download "app" "$filename"

if ! [[ -f "konsole-adjust_scrollbar-1.patch" ]]; then
	wget -c --progress=bar:force https://www.linuxfromscratch.org/patches/blfs/svn/konsole-adjust_scrollbar-1.patch
fi

export KF6_PREFIX=/usr
export QT6DIR=/opt/qt6
export QT6PREFIX=/opt/qt6
export PATH=$PATH:$QT6DIR/bin
export CMAKE_PREFIX_PATH=$QT6PREFIX:$KF6_PREFIX:$CMAKE_PREFIX_PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$QT6DIR/lib
tar xf $filename
cd $direname
( patch -N -f  -Np1 -i ../konsole-adjust_scrollbar-1.patch ) || echo "[WARNING] Patch application failed, continuing build..."
cmake_options=(
	-D CMAKE_INSTALL_LIBDIR=lib
	-D CMAKE_INSTALL_PREFIX=$KF6_PREFIX  
	-D CMAKE_BUILD_TYPE=Release
	-D BUILD_TESTING=OFF
	-W no-author
	-D libssh_DIR=/usr/lib/cmake/libssh
)
cmaki "${cmake_options[@]}"
cd ../..
#rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
