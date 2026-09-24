#!/bin/bash
set -e
name=prison
repo=KDE/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 dbus double-conversion e2fsprogs expat flac fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu keyutils lame libdmtx libdrm libelf libffi libogg libpciaccess libpng libqrencode libsndfile libvorbis libx11 libxau libxcb libxdmcp libxext libxkbcommon libxml2 libxshmfence libxxf86vm llvm lm-sensors mesa mitkrb mpg123 openssl opus pcre2 pulseaudio qt6 spirv-tools systemd wayland xz zlib zstd zxing-cpp)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
kde_download "frameworks" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr \
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
