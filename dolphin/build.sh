#!/bin/bash
set -e
name=dolphin
homepage="https://invent.kde.org/system/dolphin"
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attica attr breeze-icons brotli bzip2 dbus double-conversion e2fsprogs expat flac fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kbookmarks kcmutils kcodecs kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash kdbusaddons keyutils kfilemetadata kglobalaccel kguiaddons ki18n kiconthemes kio kitemviews kjobwidgets knewstuff knotifications kpackage kparts kservice ktextwidgets kuserfeedback kwidgetsaddons kwindowsystem kxmlgui lame libcanberra libdrm libelf libffi libogg libpciaccess libpng libsndfile libvorbis libx11 libxau libxcb libxdmcp libxext libxfixes libxkbcommon libxml2 libxshmfence libxxf86vm llvm lm-sensors mesa mitkrb mpg123 openssl opus pcre2 pulseaudio qt6 solid sonnet spirv-tools syndication systemd util-linux wayland webkitgtk xcb-util-keysyms xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
kde_download "app" "$filename"
unpk_enter "$filename" "$direname"
options=(
    -D CMAKE_INSTALL_PREFIX=/usr \      
	-D CMAKE_BUILD_TYPE=Release  \            
	-D BUILD_TESTING=OFF \
	-W no-author
)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
