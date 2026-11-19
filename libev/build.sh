#!/bin/bash
set -e
name=libev
get_version() {
	local up_ver=$(wget -cqO- -T 5 -t 1 https://dist.schmorp.de/libev/ | grep "libev-[0-9.]+.tar.gz" -oE | head -n 1 | grep -oE "[0-9]\.[0-9]+")
	local inst_ver=$(pkgver $name)
	local arch_ver=$(aver $name)
	ver_check "$up_ver" "$inst_ver" "$arch_ver" && return
	fver "$name" "$inst_ver"
}
homepage="https://software.schmorp.de/pkg/libev.html"
description="Child/pid watchers, periodic timers based on wallclock, and other features."
version=$(get_version)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://dist.schmorp.de/libev/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
