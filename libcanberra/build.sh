#!/bin/bash
set -e
name=libcanberra
repo=Distrotech/$name
version=$(gh_ver $repo)
depends=(alsa-lib at-spi2-core brotli bzip2 cairo dbus elfutils expat flac fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gstreamer gtk3 harfbuzz lame lcms2 libepoxy libffi libogg libpng libseccomp libsndfile libtool libunwind libvorbis libX11 libXau libxcb libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libXrandr libXrender libXres mpg123 opus pango pcre2 pixman pulseaudio systemd util-linux wayland xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://0pointer.de/lennart/projects/libcanberra/$filename"
unpk_enter "$filename" "$direname"
gap_patches "$name" || echo "Applying patch failed."
./configure --prefix=/usr --disable-oss
make -j$(nproc)
sudo make docdir=/usr/share/doc/$direname install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
