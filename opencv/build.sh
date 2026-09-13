#!/bin/bash
set -e
name=opencv
repo=$name/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 dbus elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gst-plugins-base gstreamer gtk3 harfbuzz libX11 libXau libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libXrandr libXrender libXres libaom libepoxy libffi libpng libxcb libxkbcommon orc pango pcre2 systemd util-linux wayland xz zlib zstd)
blfs_depends=(at-spi2-core cairo dav1d lcms2 libavif libdrm libjpeg-turbo libseccomp libtiff libunwind libwebp openjpeg pixman svt-av1 xine-lib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/archive/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
gap_patches $name
options=(-D CMAKE_INSTALL_PREFIX=/usr      \
      -D CMAKE_BUILD_TYPE=Release       \
      -D ENABLE_CXX11=ON                \
      -D BUILD_PERF_TESTS=OFF           \
      -D WITH_XINE=ON                   \
      -D BUILD_TESTS=OFF                \
      -D ENABLE_PRECOMPILED_HEADERS=OFF \
      -D CMAKE_SKIP_INSTALL_RPATH=ON    \
      -D BUILD_WITH_DEBUG_INFO=OFF      \
      -D OPENCV_GENERATE_PKGCONFIG=ON   \
      -W no-author)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
