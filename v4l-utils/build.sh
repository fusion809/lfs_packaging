#!/bin/bash
set -e
name=v4l-utils
homepage="https://linuxtv.org/"
description="Userspace tools and conversion library for Video 4 Linux"
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://www.linuxtv.org/downloads/v4l-utils/ | grep "v4l-utils-[0-9]+\.[0-9]+\.[0-9]+" -oE | sed 's/v4l-utils-//g' | sort -V | tail -n 1)
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
depends=(alsa-lib brotli bzip2 dbus double-conversion elfutils expat fontconfig freetype gcc glib2 glibc glu graphite2 harfbuzz icu json-c libdrm libffi libjpeg-turbo libpciaccess libpng libx11 libxau libxcb libxdmcp libxext libxkbcommon libxml2 libxshmfence libxxf86vm llvm lm-sensors mesa pcre2 qt6 spirv-tools systemd wayland xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://www.linuxtv.org/downloads/v4l-utils/$filename"
unpk_enter "$filename" "$direname"
options=(--prefix=/usr       \
      --buildtype=release \
      -D gconv=disabled   \
      -D doxygen-doc=disabled)
mni "${options[@]}"
for prog in v4l2gl v4l2grab
do
   sudo cp -v contrib/test/$prog /usr/bin
done
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
