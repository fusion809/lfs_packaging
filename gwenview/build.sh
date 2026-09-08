#!/bin/bash
set -e
name=gwenview
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr baloo brotli bzip2 curl cyrus-sasl dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu inih jansson karchive kbookmarks kcodecs kcolorpicker kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash keyutils kfilemetadata kglobalaccel kguiaddons ki18n kiconthemes kimageannotator kio kitemmodels kitemviews kjobwidgets knotifications kparts kservice kwidgetsaddons kwindowsystem kxmlgui libX11 libXext libXfixes libXxf86vm libffi libidn2 libpciaccess libpng libpsl libunistring libxkbcommon libxml2 libxshmfence lmdb mesa mitkrb nghttp2 openldap openssl pcre2 plasma-activities purpose solid systemd util-linux wayland webkitgtk xz zlib zstd)
blfs_depends=(breeze-icons flac lame lcms2 libXau libXdmcp libcanberra libdrm libjpeg-turbo libkdcraw libogg libraw libsndfile libtiff libvorbis libwebp libxcb llvm lm-sensors mpg123 opus pulseaudio qt6 spirv-tools xcb-util-keysyms)
lfs_depends=(libelf)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.kde.org/stable/release-service/$version/src/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr       -D CMAKE_BUILD_TYPE=Release               -D BUILD_TESTING=OFF -W no-author)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
