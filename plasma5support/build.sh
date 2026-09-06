#!/bin/bash
set -e
name=plasma5support
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr brotli bzip2 double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu keyutils libX11 libXext libXfixes libXxf86vm libffi libksysguard libpciaccess libpng libxkbcommon libxml2 libxshmfence mesa mitkrb networkmanager nspr nss openssl pcre2 plasma-activities systemd util-linux wayland xz zlib zstd)
blfs_depends=(breeze-icons karchive kauth kbookmarks kcodecs kcolorscheme kcompletion kconfig kcoreaddons kcrash kguiaddons kholidays ki18n kiconthemes kidletime kio kitemviews kjobwidgets knotifications kservice kunitconversion kwidgetsaddons kwindowsystem libXau libXdmcp libcanberra libdrm libogg libvorbis libxcb llvm lm-sensors networkmanager-qt qt6 solid spirv-tools webkitgtk xcb-util-keysyms)
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
