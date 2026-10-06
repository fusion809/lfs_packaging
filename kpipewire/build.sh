#!/bin/bash
set -e
name=kpipewire
homepage="https://kde.org/plasma-desktop/"
description="Components relating to pipewire use in Plasma."
repo=KDE/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 dav1d dbus double-conversion e2fsprogs expat fdk-aac ffmpeg fontconfig freetype fribidi gcc glib2 glibc graphite2 harfbuzz icu kcoreaddons keyutils ki18n lame libaom libass libdrm libelf libepoxy libffi libglvnd libogg libpciaccess libpng libva libvorbis libvpx libx11 libxau libxcb libxdmcp libxext libxfixes libxkbcommon libxml2 libxshmfence libxxf86vm llvm lm-sensors mesa mitkrb mpg123 numactl openssl opus pcre2 pipewire qt6 spirv-tools svt-av1 systemd util-linux wayland x264 xdg-desktop-portal-kde xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
