#!/bin/bash
set -e
name=xine-lib
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://sourceforge.net/projects/xine/files/xine-lib/ | grep "[0-9]+\.[0-9]+\.[0-9]+" -oE | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(ImageMagick alsa-lib brotli bzip2 dav1d dbus elfutils expat flac fontconfig freetype gcc gdk-pixbuf glib2 glibc glu glycin gmp gnutls icu jack lame lcms2 libICE libSM libX11 libXau libXdmcp libXext libXfixes libXinerama libXt libXv libXxf86vm liba52 libaom libdrm libdvdnav libdvdread libffi libgcrypt libgpg-error libidn2 libjpeg-turbo libmng libogg libpciaccess libpng libseccomp libsndfile libssh2 libtasn1 libtool libunistring libva libvorbis libvpx libxcb libxml2 libxshmfence lm-sensors mesa mpg123 nettle openssl opus p11-kit pcre2 pulseaudio speex spirv-tools systemd util-linux v4l-utils wayland xz zlib zstd)
blfs_depends=(llvm)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://downloads.sourceforge.net/xine/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
gap_patches "$name"
cmi --prefix=/usr --disable-vcd --disable-w32dll --with-external-dvdnav --docdir=/usr/share/doc/$direname
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
