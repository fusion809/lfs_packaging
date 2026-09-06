#!/bin/bash
set -e
name=plasma-desktop
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attica attr brotli bzip2 curl cyrus-sasl double-conversion e2fsprogs expat flatpak fontconfig freetype gcc glib2 glibc gpgme graphite2 harfbuzz ibus icu json-glib keyutils libICE libSM libX11 libXcursor libXext libXfixes libXi libXrender libXxf86vm libarchive libassuan libevdev libffi libgpg-error libgudev libidn2 libksysguard libpciaccess libplasma libpng libpsl libunistring libwacom libxkbcommon libxkbfile libxml2 libxshmfence lmdb lz4 mesa mitkrb nghttp2 openldap openssl ostree pcre2 plasma-activities plasma-activities-stats plasma-workspace polkit sqlite systemd util-linux wayland xz zlib zstd)
blfs_depends=(avahi baloo breeze-icons karchive kauth kbookmarks kcmutils kcodecs kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash kdbusaddons kfilemetadata kglobalaccel kguiaddons ki18n kiconthemes kio kirigami kitemmodels kitemviews kjobwidgets knewstuff knotifications knotifyconfig kpackage krunner kservice ksvg kwidgetsaddons kwindowsystem kxmlgui libXau libXdmcp libcanberra libdrm libogg libseccomp libsndfile libsoup libvorbis libxcb llvm lm-sensors qt6 sdl2-compat solid sonnet spirv-tools syndication webkitgtk xcb-util xcb-util-cursor xcb-util-image xcb-util-keysyms xcb-util-renderutil)
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
