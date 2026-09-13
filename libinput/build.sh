#!/bin/bash
set -e
name=libinput
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -cqO- -T 5 -t 1 https://gitlab.freedesktop.org/libinput/libinput/-/tags | grep "[0-9]+\.[0-9]+\.[0-8][0-9]*" -oE | cut -d '/' -f 3 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://gitlab.freedesktop.org/libinput/libinput.git | grep "refs/tags/[0-9]+\.[0-9]+\.[0-8][0-9]*" -oE | cut -d '/' -f 3 | sort -V | tail -n 1)
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
depends=(glibc libevdev lua mtdev systemd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force http://www.freedesktop.org/software/libinput/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
