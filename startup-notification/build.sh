#!/bin/bash
set -e
name=startup-notification
homepage="https://www.freedesktop.org/wiki/Software/startup-notification/"
description="Libary to monitor and display application startup"
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://www.freedesktop.org/software/startup-notification/releases/ | grep "startup-notification-[0-9]+\.[0-9]+" -oE | sed 's/startup-notification-//g' | sort -V | tail -n 1)
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
depends=(glibc libx11 libxau libxcb libxdmcp xcb-util)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://www.freedesktop.org/software/startup-notification/releases/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
sudo install -v -m644 -D doc/startup-notification.txt \
    /usr/share/doc/$direname/startup-notification.txt
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
