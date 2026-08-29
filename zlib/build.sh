#!/bin/bash
set -e
name=zlib
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://zlib.net/fossils | grep -E "zlib-[0-9]+\.[0-9]+" | cut -d '"' -f 4 | cut -d '-' -f 2 | sed 's/.tar.gz//g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/madler/zlib.git | grep -E "refs/tags/v[0-9.]+$" | cut -d '/' -f 3 | sed 's/^v//g' | sort -V)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}	
version=$(get_version)
lfs_depends=(gcc glibc tar make coreutils wget gzip)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://zlib.net/fossils/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr
sudo rm -fv /usr/lib/libz.a
cd ..
echo "$version" > /var/lib/custom-packages/$name
