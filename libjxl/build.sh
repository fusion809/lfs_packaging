#!/bin/bash
set -e
name=libjxl
repo=$name/$name
version=$(gh_ver $repo)
depends=(acl at-spi2-core brotli bzip2 cairo dbus expat fontconfig freetype fribidi gcc gdk-pixbuf giflib glib2 glibc glycin gpm graphite2 gtk3 harfbuzz highway lcms2 libICE libSM libX11 libXau libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libXrandr libXrender libXres libXt libaom libavif libcanberra libepoxy libffi libjpeg-turbo libogg libpng libseccomp libtool libvorbis libwebp libxcb libxkbcommon ncurses pango pcre2 pixman systemd util-linux wayland zlib)
blfs_depends=(dav1d svt-av1)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/archive/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr             \
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
