#!/bin/bash
set -e
name=kfilemetadata
homepage="https://develop.kde.org/products/frameworks/"
description="Library for extracting file metadata."
repo=KDE/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 curl cyrus-sasl dav1d dbus double-conversion e2fsprogs exiv2 expat fdk-aac ffmpeg fontconfig freetype gcc glib2 glibc gpgme gpgmepp graphite2 harfbuzz icu inih jansson karchive kcodecs kcoreaddons keyutils ki18n lame lcms2 libaom libassuan libdrm libelf libffi libglvnd libgpg-error libidn2 libjpeg-turbo libogg libpciaccess libpng libpsl libtiff libunistring libva libvorbis libvpx libwebp libx11 libxau libxcb libxdmcp libxext libxfixes libxkbcommon libxml2 libxshmfence libxxf86vm llvm lm-sensors mesa mitkrb mpg123 nghttp2 nspr nss numactl openjpeg openldap openssl opus pcre2 poppler qt6 spirv-tools svt-av1 systemd taglib texlive tiff util-linux wayland x264 x265 xdg-desktop-portal-kde xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
kde_download "frameworks" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_INSTALL_LIBEXECDIR=libexec \
    -D CMAKE_PREFIX_PATH=/opt/qt6        \
    -D CMAKE_SKIP_INSTALL_RPATH=ON      \
    -D CMAKE_BUILD_TYPE=Release         \
    -D BUILD_TESTING=OFF                \
    -D BUILD_PYTHON_BINDINGS=OFF        \
	-W no-author)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
