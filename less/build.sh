#!/bin/bash
set -e
name=less
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 2 -t 1 -cqO- https://www.kernel.org/pub/linux/docs/man-pages/ | grep "man-pages-[0-9.]+" -E | cut -d '"' -f 2 | sed 's/man-pages-//g' | sed 's/.tar.*//g' | sort -V | uniq | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 2 git ls-remote --tags --refs https://github.com/gwsw/less.git | grep -E "refs/tags/v[0-9]+-rel" | cut -d '/' -f 3 | sed 's/^v//g' | sed 's/-rel//g' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
lfs_depends=(glibc ncurses pcre2)
if ! [[ -f $filename ]]; then
	wget -c https://www.greenwoodsoftware.com/less/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --sysconfdir=/etc
cd ..
rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
