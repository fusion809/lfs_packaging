#!/bin/bash
set -e
name=pangomm
repo=GNOME/$name
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(ght_ver $repo $name)
	local git_ver=$(ghl_ver $repo $name)
	ver_check "$git_ver" "$inst_ver" "$up_ver" && return
	fver "$name" "$inst_ver"
}
homepage="https://github.com/GNOME/pangomm"
description="Provides a C++ interface to Pango."
version=$(get_version)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(brotli bzip2 cairo cairomm expat fontconfig freetype fribidi gcc glib2 glibc glibmm glibmm24 graphite2 harfbuzz libffi libpng libselinux libsigcpp2 libx11 libxau libxcb libxdmcp libxext libxrender pango pcre2 pixman systemd util-linux zlib)
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release -D maintainer-mode=true -D build-documentation=false
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
