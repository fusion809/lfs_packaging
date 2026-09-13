#!/bin/bash
set -e
name=libcanberra
repo=Distrotech/$name
version=$(gh_ver $repo)
depends=(alsa-lib at-spi2-core brotli bzip2 cairo dbus elfutils expat flac fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gstreamer gtk3 harfbuzz lame lcms2 libX11 libXau libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libXrandr libXrender libXres libepoxy libffi libpng libseccomp libtool libunwind libxcb libxkbcommon mpg123 pango pcre2 pixman pulseaudio systemd util-linux wayland xz zlib zstd)
blfs_depends=(libogg libsndfile libvorbis opus)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://0pointer.de/lennart/projects/libcanberra/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
gap_patches "$name"
./configure --prefix=/usr --disable-oss
make -j$(nproc)
sudo make docdir=/usr/share/doc/$direname install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
