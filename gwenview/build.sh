#!/bin/bash
set -e
name=gwenview
homepage="https://apps.kde.org/gwenview/"
description="Fast and easy to use image viewer."
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr baloo breeze-icons brotli bzip2 curl cyrus-sasl dbus double-conversion e2fsprogs exiv2 expat flac fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu inih jansson karchive kbookmarks kcodecs kcolorpicker kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash keyutils kfilemetadata kglobalaccel kguiaddons ki18n kiconthemes kimageannotator kio kitemmodels kitemviews kjobwidgets knotifications kparts kservice kwidgetsaddons kwindowsystem kxmlgui lame lcms2 libcanberra libdrm libelf libffi libglvnd libidn2 libjpeg-turbo libkdcraw libogg libpciaccess libpng libpsl libraw libsndfile libtiff libtool libunistring libvorbis libwebp libx11 libxau libxcb libxdmcp libxext libxfixes libxkbcommon libxml2 libxshmfence libxxf86vm llvm lm-sensors lmdb mesa mitkrb mpg123 nghttp2 openldap openssl opus pcre2 plasma-activities pulseaudio purpose qt6 solid spirv-tools systemd tiff util-linux wayland webkitgtk xcb-util-keysyms xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
kde_download "app" "$filename"
unpk_enter "$filename" "$direname"
options=(
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_BUILD_TYPE=Release \
	-D BUILD_TESTING=OFF \
	-W no-author)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
