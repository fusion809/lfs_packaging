#!/bin/bash
set -e
name=luit
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -cqO- -T 5 -t 1 https://invisible-mirror.net/archives/luit/ | grep -oE "luit-[0-9]+" | cut -d '-' -f 2 | sort -V | tail -n 1)
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(glibc zlib)
filename="$name-$version.tgz"
direname="${filename/.tgz/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://invisible-mirror.net/archives/luit/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
