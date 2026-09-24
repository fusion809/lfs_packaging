#!/bin/bash
set -e
name=libwebp
repo=webmproject/$name
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://github.com/webmproject/libwebp/tags/ | grep "v1\.[0-9]\.[0-9]" -oE | sed 's/^v//g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/webmproject/libwebp.git | grep "refs/tags/v[0-9.]+" -oE | sed 's/.*v//g' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(bzip2 elfutils expat freeglut gcc giflib glibc icu libdrm libffi libjpeg-turbo libpciaccess libpng libx11 libxau libxcb libxdmcp libxext libxi libxml2 libxrandr libxrender libxshmfence libxxf86vm llvm lm-sensors mesa spirv-tools tiff xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://storage.googleapis.com/downloads.webmproject.org/releases/webp/$filename"
unpk_enter "$filename" "$direname"
options=(--prefix=/usr           \
            --enable-libwebpmux     \
            --enable-libwebpdemux   \
            --enable-libwebpdecoder \
            --enable-libwebpextras  \
            --enable-swap-16bit-csp \
	    --disable-static)
cmi "${options[@]}"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
