#!/bin/bash
set -e
name=libinput
homepage="https://wayland.freedesktop.org/libinput/doc/latest/"
description="Input device management and event handling library"
repo=$name/$name
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -cqO- -T 5 -t 1 https://gitlab.freedesktop.org/$repo/-/tags | grep "[0-9]+\.[0-9]+\.[0-8][0-9]*" -oE | cut -d '/' -f 3 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://gitlab.freedesktop.org/$repo.git | grep "refs/tags/[0-9]+\.[0-9]+\.[0-8][0-9]*" -oE | cut -d '/' -f 3 | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(glibc libevdev lua mtdev systemd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gfd_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
