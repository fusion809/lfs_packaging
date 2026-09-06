#!/bin/bash
set -e
name=plasma-workspace
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr brotli bzip2 curl cyrus-sasl double-conversion e2fsprogs expat flatpak fontconfig freetype gcc glib2 glibc gmp gpgme graphite2 harfbuzz icu json-glib keyutils knighttime kscreenlocker layer-shell-qt libICE libSM libX11 libXcursor libXext libXfixes libXft libXi libXrender libXtst libXxf86vm libarchive libassuan libdmtx libffi libfyaml libgpg-error libidn2 libksysguard libpciaccess libplasma libpng libpsl libqalculate libunistring libxcrypt libxkbcommon libxml2 libxmlb libxshmfence lmdb lz4 mesa mitkrb mpfr networkmanager nghttp2 nspr nss openldap openssl ostree pcre2 plasma-activities plasma-activities-stats polkit sqlite systemd util-linux wayland xz zlib zstd)
blfs_depends=(attica avahi baloo breeze-icons flac karchive kauth kbookmarks kcmutils kcodecs kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash kdbusaddons kdeclarative kfilemetadata kglobalaccel kguiaddons kholidays ki18n kiconthemes kidletime kio kirigami kitemmodels kitemviews kjobwidgets knewstuff knotifications kpackage kparts krunner kservice kstatusnotifieritem ksvg ktexteditor ktextwidgets kuserfeedback kwallet kwidgetsaddons kwindowsystem kxmlgui lame libXau libXdmcp libcanberra libdrm libogg libqrencode libseccomp libsndfile libsoup libvorbis libxcb llvm lm-sensors mpg123 networkmanager-qt opus polkit-qt prison pulseaudio qt6 solid sonnet spirv-tools syndication syntax-highlighting webkitgtk xcb-util xcb-util-cursor xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm zxing-cpp)
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
