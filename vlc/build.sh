#!/bin/bash
set -e
name=vlc
repo=videolan/$name
version=$(gh_ver $repo | sed 's/_[0-9]//g' | sed -E '/^[^.]*\.[^.]*\.[^.]*\.[^.]*$/ s/\.[0-9]$//')
depends=(acl brotli bzip2 cyrus-sasl dbus double-conversion e2fsprogs elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin gmp gnutls graphite2 gst-plugins-base gstreamer gtk3 harfbuzz icu jack jansson keyutils libICE libSM libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXpm libXrandr libXrender libXres libXxf86vm libaom libarchive libcap libepoxy libffi libgcrypt libgpg-error libidn2 libnotify libpciaccess libpng librsvg libsecret libssh2 libtasn1 libunistring libvpx libxkbcommon libxml2 libxshmfence lua lz4 mesa mitkrb ncurses nettle numactl openldap openssl orc p11-kit pango pcre2 pulseaudio systemd util-linux wayland x265 xz zlib zstd)
blfs_depends=(alsa-lib at-spi2-core avahi cairo dav1d flac lame lcms2 libXau libXdmcp libass libdrm libdvdnav libdvdread libjpeg-turbo libogg libseccomp libsndfile libunwind libva libvorbis libxcb llvm lm-sensors mpg123 opus pixman qt6 speex spirv-tools taglib x264 xcb-util-keysyms)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.videolan.org/vlc/$version/$filename
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
