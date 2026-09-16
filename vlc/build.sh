#!/bin/bash
set -e
name=vlc
repo=videolan/$name
version=$(gh_ver $repo | sed 's/_[0-9]//g' | sed -E '/^[^.]*\.[^.]*\.[^.]*\.[^.]*$/ s/\.[0-9]$//')
depends=(acl alsa-lib at-spi2-core avahi brotli bzip2 cairo cyrus-sasl dav1d dbus double-conversion e2fsprogs elfutils expat flac fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin gmp gnutls graphite2 gst-plugins-base gstreamer gtk3 harfbuzz icu jack jansson keyutils lame lcms2 libaom libarchive libass libcap libdrm libdvdnav libdvdread libepoxy libffi libgcrypt libgpg-error libICE libidn2 libjpeg-turbo libnotify libogg libpciaccess libpng librsvg libseccomp libsecret libSM libsndfile libssh2 libtasn1 libunistring libunwind libva libvorbis libvpx libX11 libXau libxcb libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libXpm libXrandr libXrender libXres libxshmfence libXxf86vm llvm lm-sensors lua lz4 mesa mitkrb mpg123 ncurses nettle numactl openldap openssl opus orc p11-kit pango pcre2 pixman pulseaudio qt6 speex spirv-tools systemd taglib util-linux wayland x264 x265 xcb-util-keysyms xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.videolan.org/vlc/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i 's/gstvideopool.h/video.h/' modules/codec/gstreamer/gstvlcvideopool.h
BUILDCC=gcc ./configure --prefix=/usr &&
	make -j$(nproc)
sudo make docdir=/usr/share/doc/$direname install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
