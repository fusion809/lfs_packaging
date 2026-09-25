#!/bin/bash
set -e
name=libdvdnav
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://code.videolan.org/videolan/$name.git | cut -d '/' -f 3 | sort -V | tail -n 1)
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
depends=(glibc)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
#download_src "https://get.videolan.org/$name/$version/$filename"
download_src "https://mirror.aarnet.edu.au/pub/videolan/$name/$version/$filename"
unpk_enter "$filename" "$direname"
sed -i "/get_option/s/$name/&-$version/" meson.build
options=(--prefix=/usr       \
            --buildtype=release \
	    --default-library=shared)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
