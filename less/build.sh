#!/bin/bash
set -e
name=less
description="A terminal based program for viewing text files"
homepage="https://gnu.org/s/less/"
get_version() {
	local lfs_vers=$(lfs_ver $name)
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://www.kernel.org/pub/linux/docs/man-pages/ | grep "man-pages-[0-9.]+" -E | cut -d '"' -f 2 | sed 's/man-pages-//g' | sed 's/.tar.*//g' | sort -V | uniq | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/gwsw/less.git | grep -E "refs/tags/v[0-9]+-rel" | cut -d '/' -f 3 | sed 's/^v//g' | sed 's/-rel//g' | sort -V | tail -n 1)
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
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(glibc ncurses pcre2)
download_src "https://www.greenwoodsoftware.com/less/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --sysconfdir=/etc
cd ..
rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
