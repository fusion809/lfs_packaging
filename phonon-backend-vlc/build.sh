#!/bin/bash
set -e
name=phonon-backend-vlc
repo=KDE/phonon-vlc
version=$(gh_ver $repo)
depends=(brotli bzip2 dbus double-conversion expat flac fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu lame libdrm libelf libffi libogg libpciaccess libpng libsndfile libvorbis libx11 libxau libxcb libXdmcp libXext libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa mpg123 opus pcre2 phonon pulseaudio qt6 spirv-tools systemd vlc wayland xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
kde_download "$filename"
unpk_enter "$filename" "$direname"
options=(
	-D CMAKE_INSTALL_PREFIX=/usr 
	-D CMAKE_BUILD_TYPE=Release 
	-D PHONON_BUILD_QT5=OFF)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
