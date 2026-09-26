#!/bin/bash
set -e
name=traceroute
description="Tracks the route taken by packets over an IP network"
homepage="http://traceroute.sourceforge.net/"
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://sourceforge.net/projects/traceroute/files/traceroute/ | grep "traceroute-[0-9]+\.[0-9]+\.[0-9]+" -oE | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
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
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
sf_download "$name" "$direname" "$filename"
unpk_enter "$filename" "$direname"
make -j$(nproc)
sudo su -c "make prefix=/usr install                                 &&
ln -sv -f traceroute /usr/bin/traceroute6                &&
ln -sv -f traceroute.8 /usr/share/man/man8/traceroute6.8 &&
rm -fv /usr/share/man/man1/traceroute.1"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
