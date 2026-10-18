#!/bin/bash
set -e
name=msgpack-c
repo=msgpack/$name
get_version() {
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/$repo.git \
		| grep "c-[0-9.]+" -oE | cut -d '-' -f 2 | sort -V | tail -n )
	local inst_ver=$(pkgver $name)
	local arch_ver=$(aver $name)
	ver_check "$git_ver" "$inst_ver" "$arch_ver" && return
	local up_ver=(wget -cqO- -T 5 -t 1 https://github.com/$repo/tags \
		| grep "tag/c-[0-9.]+" -oE | head -n 1 | cut -d '-' -f 2)

	ver_check "$up_ver" "$inst_ver" "$arch_ver" && return
	local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$arch_ver" && return
	fver "$name" "$inst_ver"
}
homepage="https://github.com/msgpack/msgpack-c"
description="MessagePack implementation for C."
version=$(get_version)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
tag="c-$version"
ghr_download "$repo" "$tag" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=None \
    -Wno-dev \
    -DBUILD_SHARED_LIBS=ON \
    -DMSGPACK_ENABLE_STATIC=OFF \
    -DMSGPACK_BUILD_EXAMPLES=OFF \
    -DMSGPACK_BUILD_TESTS=OFF)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
