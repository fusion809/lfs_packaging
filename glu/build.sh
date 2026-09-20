#!/bin/bash
set -e
name=glu
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://archive.mesa3d.org/glu/ | grep "glu-[0-9]+\.[0-9]+\.[0-9]+" -oE | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://gitlab.freedesktop.org/mesa/glu.git | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(bzip2 expat gcc glibc icu libdrm libelf libffi libglvnd libpciaccess libX11 libXau libxcb libXdmcp libXext libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa spirv-tools xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://archive.mesa3d.org/glu/$filename"
unpk_enter "$filename" "$direname"
meson_options=(
	--prefix=/usr \
	--buildtype=release)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
