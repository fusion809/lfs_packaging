#!/bin/bash
set -e
name=plasma-workspace
homepage="https://kde.org/plasma-desktop/"
description="KDE Plasma Workspace"
repo=KDE/$name
version=$(gh_ver $repo)
# appstream needs qt support
depends=(acl appstream attica attr avahi baloo breeze-icons brotli bzip2 curl cyrus-sasl dbus double-conversion e2fsprogs expat flac flatpak fontconfig freetype gcc glib2 glibc gmp gpgme graphite2 harfbuzz icu json-glib karchive kauth kbookmarks kcmutils kcodecs kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash kdbusaddons kdeclarative keyutils kfilemetadata kglobalaccel kguiaddons kholidays ki18n kiconthemes kidletime kio kirigami kitemmodels kitemviews kjobwidgets knewstuff knighttime knotifications kpackage kparts krunner kscreenlocker kservice kstatusnotifieritem ksvg ktexteditor ktextwidgets kuserfeedback kwallet kwidgetsaddons kwindowsystem kxmlgui lame layer-shell-qt libarchive libassuan libcanberra libdmtx libdrm libelf libffi libfyaml libgpg-error libice libidn2 libksysguard libogg libpciaccess libplasma libpng libpsl libqalculate libqrencode libseccomp libSM libsndfile libsoup libunistring libvorbis libx11 libxau libxcb libxcrypt libxcursor libxdmcp libxext libxfixes libxft libxi libxkbcommon libxml2 libxmlb libxrender libxshmfence libxtst libxxf86vm llvm lmdb lm-sensors lz4 mesa mitkrb mpfr mpg123 networkmanager networkmanager-qt nghttp2 nspr nss openldap openssl opus ostree pcre2 plasma-activities plasma-activities-stats polkit polkit-qt prison pulseaudio qt6 solid sonnet spirv-tools sqlite syndication syntax-highlighting systemd util-linux wayland webkitgtk xcb-util xcb-util-cursor xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm xz zlib zstd zxing-cpp)
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
