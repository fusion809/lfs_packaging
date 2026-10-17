#!/bin/bash
set -e
name=libspectre
get_version () {
	local inst_ver=$(pkgver $name)
	local url="https://libspectre.freedesktop.org/releases/"
	local up_ver=$(wget -cqO- -T 5 -t 1 $url \
		| grep "$name-[0-9.]+.tar.gz" -oE | uniq | sed 's/.tar.gz//g' \
		| sed 's/libspectre-//g' | sort -V | tail -n 1)
	local mon_ver=$(uver $name)
	ver_check "$up_ver" "$inst_ver" "$mon_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$mon_ver" && return
}
homepage="https://libspectre.freedesktop.org/"
description="Library for postscript documents."
version=$(get_version)
depends=(avahi brotli bzip2 cups dbus expat fontconfig freetype gcc ghostscript glibc lcms2 libice libjpeg-turbo libpaper libpng libsm libwebp libx11 libxau libxcb libxcrypt libxdmcp libxext libxt openjpeg openssl systemd tiff util-linux xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://libspectre.freedesktop.org/releases/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
