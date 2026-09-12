#!/bin/bash
set -e
name=xcb-proto
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://gitlab.freedesktop.org/xorg/proto/xcbproto/-/tags | grep "xcb-proto-[0-9]+\.[0-9]+\.[0-9]+" -oE | sed 's/xcb-proto-//g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://gitlab.freedesktop.org/xorg/proto/xcbproto.git | grep "xcb-proto-[0-9]+\.[0-9]+\.[0-9]+" -oE | sed 's/xcb-proto-//g' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://xorg.freedesktop.org/archive/individual/proto/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
PYTHON=python3 cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
