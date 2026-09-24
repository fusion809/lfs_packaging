#!/bin/bash
set -e
name=xine-lib
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://sourceforge.net/projects/xine/files/xine-lib/ | grep "[0-9]+\.[0-9]+\.[0-9]+" -oE | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(alsa-lib brotli bzip2 dav1d dbus elfutils expat flac fontconfig freetype gcc gdk-pixbuf glib2 glibc glu glycin gmp gnutls icu imagemagick jack lame lcms2 liba52 libaom libdrm libdvdnav libdvdread libffi libgcrypt libgpg-error libice libidn2 libjpeg-turbo libmng libogg libpciaccess libpng libseccomp libSM libsndfile libssh2 libtasn1 libtool libunistring libva libvorbis libvpx libX11 libXau libxcb libXdmcp libXext libXfixes libXinerama libxml2 libxshmfence libxt libXv libXxf86vm llvm lm-sensors mesa mpg123 nettle openssl opus p11-kit pcre2 pulseaudio speex spirv-tools systemd util-linux v4l-utils wayland xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://downloads.sourceforge.net/xine/$filename"
unpk_enter "$filename" "$direname"
gap_patches "$name"
cmi --prefix=/usr --disable-vcd --disable-w32dll --with-external-dvdnav --docdir=/usr/share/doc/$direname
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
