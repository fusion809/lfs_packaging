#!/bin/bash
set -e
name=man-pages
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://www.kernel.org/pub/linux/utils/kernel/kmod/ | grep -E "$name-[0-9]+\.[0-9]+\.[0-9]+" | cut -d '"' -f 2 | sed 's/.tar.*//g' | cut -d '-' -f 2 | sort -V | uniq | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://git.kernel.org/pub/scm/docs/man-pages/man-pages.git | grep -E "refs/tags/man-pages-[0-9]+\.[0-9]+\.[0-9]+" | cut -d '/' -f 3 | sed -E 's/man-pages-//g' | sort -V | sed -E 's/^1\.//g' | tail -n 1)
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
depends=(bash coreutils gcc glibc make tar xz)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://www.kernel.org/pub/linux/docs/$name/$filename"
unpk_enter "$filename"
rm -v man3/crypt*
sudo make -R GIT=false prefix=/usr install
cd ../..
sudo rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
