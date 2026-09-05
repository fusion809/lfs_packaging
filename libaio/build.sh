#!/bin/bash
set -e
name=libaio
get_version() {
	local inst_ver=$(pkgver $name)
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://pagure.io/libaio.git | grep "refs/tags/libaio-[0-9.]+$" -oE | cut -d '-' -f 2)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://releases.pagure.org/libaio/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i '/install.*libaio.a/s/^/#/' src/Makefile
maki
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
