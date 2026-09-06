#!/bin/bash
set -e
name=kwin
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr brotli bzip2 double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu kdecoration keyutils kglobalacceld knighttime kscreenlocker libICE libSM libX11 libXext libXfixes libXi libXxf86vm libdisplay-info libepoxy libevdev libffi libpciaccess libpng libxkbcommon libxml2 libxshmfence mesa mitkrb mtdev openssl pcre2 plasma-activities systemd util-linux vulkan-loader wayland xz zlib zstd)
blfs_depends=(attica breeze-icons karchive kauth kcmutils kcodecs kcolorscheme kconfig kconfigwidgets kcoreaddons kcrash kdbusaddons kglobalaccel kguiaddons kholidays ki18n kiconthemes kidletime kio kitemviews kjobwidgets knewstuff knotifications kpackage kservice ksvg kwidgetsaddons kwindowsystem kxmlgui lcms2 libXau libXdmcp libcanberra libdrm libei libinput libogg libvorbis libxcb libxcvt llvm lm-sensors lua pipewire qt6 solid spirv-tools syndication webkitgtk xcb-util-keysyms xcb-util-wm)
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
