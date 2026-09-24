#!/bin/bash
set -e
name=libjxl
repo=$name/$name
version=$(gh_ver $repo)
depends=(acl at-spi2-core brotli bzip2 cairo dav1d dbus expat fontconfig freetype fribidi gcc gdk-pixbuf giflib glib2 glibc glycin gpm graphite2 gtk3 harfbuzz highway lcms2 libaom libavif libcanberra libepoxy libffi libice libjpeg-turbo libogg libpng libseccomp libSM libtool libvorbis libwebp libX11 libXau libxcb libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libXrandr libXrender libXres libxt ncurses pango pcre2 pixman svt-av1 systemd util-linux wayland zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
options=(
      -D CMAKE_INSTALL_PREFIX=/usr             \
      -D CMAKE_BUILD_TYPE=Release              \
      -D BUILD_TESTING=OFF                     \
      -D BUILD_SHARED_LIBS=ON                  \
      -D JPEGXL_ENABLE_SKCMS=OFF               \
      -D JPEGXL_ENABLE_SJPEG=OFF               \
      -D JPEGXL_ENABLE_PLUGINS=OFF             \
      -D JPEGXL_INSTALL_JARDIR=/usr/share/java \
      -G Ninja)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
