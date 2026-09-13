#!/bin/bash
set -e
name=dolphin
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attica attr brotli bzip2 double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kbookmarks kcmutils kcodecs kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash kdbusaddons keyutils kfilemetadata kglobalaccel kguiaddons ki18n kiconthemes kio kitemviews kjobwidgets knewstuff knotifications kpackage kparts kservice ktextwidgets kuserfeedback kwidgetsaddons kwindowsystem kxmlgui libX11 libXext libXfixes libXxf86vm libffi libpciaccess libpng libxkbcommon libxml2 libxshmfence mesa mitkrb openssl pcre2 solid sonnet syndication systemd util-linux wayland webkitgtk xz zlib zstd)
blfs_depends=(breeze-icons flac lame libXau libXdmcp libcanberra libdrm libogg libsndfile libvorbis libxcb llvm lm-sensors mpg123 opus pulseaudio qt6 spirv-tools xcb-util-keysyms)
lfs_depends=(dbus libelf)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.kde.org/stable/release-service/$version/src/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr       -D CMAKE_BUILD_TYPE=Release               -D BUILD_TESTING=OFF -W no-author)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
