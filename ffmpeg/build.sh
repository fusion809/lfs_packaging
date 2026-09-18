#!/bin/bash
set -e
name=ffmpeg
repo=$name/$name
version=$(gh_ver $repo)
depends=(alsa-lib brotli bzip2 dav1d expat fdk-aac fontconfig freetype fribidi gcc glib2 glibc graphite2 harfbuzz lame libaom libass libdrm libogg libpng libva libvorbis libvpx libX11 libXau libxcb libXdmcp libXext libXfixes libXv numactl openssl opus pcre2 sdl2-compat svt-av1 x264 x265 xz zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://ffmpeg.org/releases/$filename"
unpk_enter "$filename" "$direname"
gap_patches $name || echo "Patching failed."
options=(--prefix=/usr \
	--enable-gpl         \
            --enable-version3    \
            --enable-nonfree     \
            --disable-static     \
            --enable-shared      \
            --disable-debug      \
            --enable-libaom      \
            --enable-libass      \
            --enable-libfdk-aac  \
            --enable-libfreetype \
            --enable-libmp3lame  \
            --enable-libopus     \
            --enable-libvorbis   \
            --enable-libvpx      \
            --enable-libx264     \
            --enable-libx265     \
            --enable-openssl     \
            --enable-libdav1d    \
            --enable-libsvtav1   \
            --ignore-tests=enhanced-flv-av1,enhanced-flv-multitrack \
	    --docdir=/usr/share/doc/$direname)
cmi "${options[@]}"
gcc tools/qt-faststart.c -o tools/qt-faststart
sudo su -c "install -v -m755    tools/qt-faststart /usr/bin &&
install -v -m755 -d           /usr/share/doc/$direname &&
install -v -m644    doc/*.txt /usr/share/doc/$direname"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
