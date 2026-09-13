#!/bin/bash
set -e
name=ffmpeg
repo=$name/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 expat fontconfig freetype fribidi gcc glib2 glibc graphite2 harfbuzz libX11 libXext libXfixes libXv libaom libpng libvpx numactl openssl pcre2 sdl2-compat x265 xz zlib)
blfs_depends=(alsa-lib dav1d fdk-aac lame libXau libXdmcp libass libdrm libogg libva libvorbis libxcb opus svt-av1 x264)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://ffmpeg.org/releases/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
gap_patches $name
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
