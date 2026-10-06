#!/bin/bash
set -e
name=kate
homepage="https://apps.kde.org/kate/"
description="Advanced text editor."
version=$(kap_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(acl attica attr breeze-icons brotli bzip2 dbus double-conversion e2fsprogs expat flac fontconfig frameworks6 freetype gcc glib2 glibc gpgme gpgmepp graphite2 harfbuzz icu karchive kauth kbookmarks kcodecs kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash kdbusaddons keyutils kglobalaccel kguiaddons ki18n kiconthemes kio kitemviews kjobwidgets knewstuff knotifications kpackage kparts kservice ktexteditor kuserfeedback kwidgetsaddons kwindowsystem kxmlgui lame libassuan libcanberra libffi libgcrypt libglvnd libgpg-error libogg libpng libsecret libsndfile libtool libvorbis libx11 libxau libxcb libxdmcp libxfixes libxkbcommon mitkrb mpg123 openssl opus pcre2 pulseaudio qt6 qtkeychain solid sonnet syndication syntax-highlighting systemd util-linux wayland xcb-util-keysyms xz zlib zstd)
kde_download "app" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(
      -D CMAKE_INSTALL_PREFIX=/usr  \
      -D CMAKE_BUILD_TYPE=Release          \
      -D BUILD_TESTING=OFF                 \
      -W no-author)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
