#!/bin/bash
set -e
name=spirv-headers
_name=SPIRV-Headers-vulkan-sdk
get_version() {
	local inst_ver=$(pkgver $name)
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/KhronosGroup/SPIRV-Headers.git | grep -oE "[0-9]\.[0-9]\.[0-9]+\.[0-9]" | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/KhronosGroup/SPIRV-Headers/archive/vulkan-sdk-$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -G Ninja
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
