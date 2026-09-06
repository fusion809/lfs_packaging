#!/bin/bash
set -e
name=bluedevil
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr brotli bzip2 double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu keyutils libX11 libXext libXfixes libXxf86vm libffi libpciaccess libplasma libpng libxkbcommon libxml2 libxshmfence mesa mitkrb openssl pcre2 plasma-activities systemd util-linux wayland xz zlib zstd)
blfs_depends=(bluez-qt breeze-icons karchive kbookmarks kcmutils kcodecs kcolorscheme kcompletion kconfig kcoreaddons kcrash kdbusaddons kglobalaccel kguiaddons ki18n kiconthemes kio kirigami kitemviews kjobwidgets knotifications kpackage kservice ksvg kwidgetsaddons kwindowsystem libXau libXdmcp libcanberra libdrm libogg libvorbis libxcb llvm lm-sensors qt6 solid spirv-tools webkitgtk xcb-util-keysyms)
lfs_depends=(dbus libelf)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/refs/tags/v$version.tar.gz -O $filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
