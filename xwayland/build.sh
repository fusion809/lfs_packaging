#!/bin/bash
set -e
name=xwayland
url="https://www.x.org/pub/individual/xserver/"
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -cqO- -T 5 -t 1 $url | grep "xwayland-[0-9.]+.tar.xz\"" -oE | sed 's/.tar.xz"//g' | sed 's/xwayland-//g' | grep -v "99" | sort -V | tail -n 1)
	local lfs_vers=$(lfs_ver $name)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
homepage="https://www.x.org"
description="Provides Xorg server running on top of a Wayland session."
version=$(get_version)
depends=(brotli bzip2 expat freetype gcc glibc libdrm libei libepoxy libffi libfontenc libglvnd libpng libtirpc libx11 libxau libxcb libxcvt libxdmcp libxfont2 libxshmfence mesa nettle pixman systemd wayland zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://www.x.org/pub/individual/xserver/$filename"
unpk_enter "$filename" "$direname"
sed -i -e '/install_man/,$d' meson.build &&
mni --prefix=/usr --buildtype=release -D xkb_output_dir=/var/lib/xkb
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
