#!/bin/bash
set -e
name=libwebp
repo=webmproject/$name
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://github.com/webmproject/libwebp/tags/ | grep "v1\.[0-9]\.[0-9]" -oE | sed 's/^v//g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/webmproject/libwebp.git | grep "refs/tags/v[0-9.]+" -oE | sed 's/.*v//g' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(bzip2 elfutils expat freeglut gcc giflib glibc icu libX11 libXau libXdmcp libXext libXi libXrandr libXrender libXxf86vm libffi libjpeg-turbo libpciaccess libpng libxcb libxml2 libxshmfence mesa tiff xz zlib zstd)
blfs_depends=(libdrm llvm lm-sensors spirv-tools)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://storage.googleapis.com/downloads.webmproject.org/releases/webp/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
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
