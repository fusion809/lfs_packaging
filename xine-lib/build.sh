#!/bin/bash
set -e
name=xine-lib
homepage="https://www.xine-project.org"
description="Multimedia playback engine."
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://sourceforge.net/projects/xine/files/xine-lib/ | grep "xine-lib/[0-9]+\.[0-9]+\.[0-9]+" -oE | cut -d '/' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(alsa-lib brotli bzip2 cyrus-sasl dav1d dbus e2fsprogs elfutils expat fdk-aac ffmpeg flac fontconfig freetype gcc gdk-pixbuf glib2 glibc glu glycin gmp gnutls icu imagemagick jack jansson keyutils lame lcms2 liba52 libaom libcap libdrm libdvdnav libdvdread libffi libgcrypt libglvnd libgpg-error libice libidn2 libjpeg-turbo libmad libmng libogg libpciaccess libpng libseccomp libsm libsndfile libssh2 libtasn1 libtool libunistring libva libvorbis libvpx libx11 libxau libxcb libxdmcp libxext libxfixes libxinerama libxml2 libxshmfence libxt libxv libxxf86vm llvm lm-sensors mesa mitkrb mpg123 nettle numactl openldap openssl opus p11-kit pcre2 pulseaudio samba speex spirv-tools svt-av1 systemd util-linux v4l-utils wayland x264 xdg-desktop-portal-kde xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://downloads.sourceforge.net/xine/$filename"
unpk_enter "$filename" "$direname"
gap_patches "$name"
cmi --prefix=/usr --disable-vcd --disable-w32dll --with-external-dvdnav --docdir=/usr/share/doc/$direname
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
