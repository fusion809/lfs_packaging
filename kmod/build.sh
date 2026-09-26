#!/bin/bash
set -e
name=kmod
homepage="https://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git"
description="Linux kernel module management tools and library"
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://www.kernel.org/pub/linux/utils/kernel/kmod/ | grep -E "$name-[0-9]+\.[0-9]+\.[0-9]+" | cut -d '"' -f 2 | sed 's/.tar.*//g' | cut -d '-' -f 2 | sort -V | uniq | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git | grep -E "refs/tags/v[0-9]+\.[0-9]+\.[0-9]+" | cut -d '/' -f 3 | sed 's/^v//g' | sort -V | tail -n 1)
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
depends=(bash coreutils gcc glibc make openssl tar xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://www.kernel.org/pub/linux/utils/kernel/$name/$filename"
unpk_enter "$filename" "$direname"
meson_options=(
	--prefix=/usr    \
    --buildtype=release \
	-D manpages=false)
mni "${meson_options[@]}"
cd ../..
echo $version | sudo tee /var/lib/custom-packages/$name
