#!/bin/bash
set -e
name=vlc
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://download.videolan.org/vlc/ | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
	local arch_ver=$(aver $name | sed 's/_[0-9]//g')
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local artix_ver=$(artver $name | sed 's/_[0-9]//g')
	ver_check "$artix_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$version"
}
version=$(get_version)
depends=(acl alsa-lib at-spi2-core avahi brotli bzip2 cairo cyrus-sasl dav1d dbus double-conversion e2fsprogs elfutils expat flac fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin gmp gnutls graphite2 gst-plugins-base gstreamer gtk3 harfbuzz icu jack jansson keyutils lame lcms2 libaom libarchive libass libcap libdrm libdvdnav libdvdread libepoxy libffi libgcrypt libgpg-error libice libidn2 libjpeg-turbo libnotify libogg libpciaccess libpng librsvg libseccomp libsecret libSM libsndfile libssh2 libtasn1 libunistring libunwind libva libvorbis libvpx libx11 libxau libxcb libxcomposite libxcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libXpm libXrandr libXrender libXres libxshmfence libXxf86vm llvm lm-sensors lua lz4 mesa mitkrb mpg123 ncurses nettle numactl openldap openssl opus orc p11-kit pango pcre2 pixman pulseaudio qt6 speex spirv-tools systemd taglib util-linux wayland x264 x265 xcb-util-keysyms xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://download.videolan.org/vlc/$version/$filename"
unpk_enter "$filename" "$direname"
sed -i 's/gstvideopool.h/video.h/' modules/codec/gstreamer/gstvlcvideopool.h
BUILDCC=gcc ./configure --prefix=/usr &&
	make -j$(nproc)
sudo make docdir=/usr/share/doc/$direname install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
