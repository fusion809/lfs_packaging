#!/bin/bash
set -e
name=ssw
_name=spread-sheet-widget
get_version() {
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://salsa.debian.org/beckmanf/spread-sheet-widget.git | grep "refs/tags/upstream/[0-9.]+" -oE | cut -d '/' -f 4 | sort -V | tail -n 1)
	local inst_ver=$(pkgver $name)
	local arch_ver=$(aurver $_name)
	ver_check "$git_ver" "$inst_ver" "$arch_ver" && return
	local up_ver=$(wget -cqO- -T 5 -t 1 https://salsa.debian.org/beckmanf/spread-sheet-widget/-/tags | grep "upstream/[0-9.]+" -oE | cut -d '/' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$arch_ver" && return
	fver "$name" "$inst_ver"
}
homepage=""
description="GTK+ library for viewing/manipulating 2D tabular data."
version=$(get_version)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://alpha.gnu.org/gnu/ssw/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
