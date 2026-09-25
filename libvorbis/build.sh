#!/bin/bash
set -e
name=libvorbis
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://gitlab.xiph.org/xiph/vorbis/-/tags | grep "v[0-9]+\.[0-9]+\.[0-9]+" -oE | sed 's/^v//g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://gitlab.xiph.org/xiph/vorbis.git | grep "refs/tags/v[0-9]+\.[0-9]+\.[0-9]+$" -oE | sed 's/.*v//g' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(glibc libogg)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://downloads.xiph.org/releases/vorbis/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
sudo install -v -m644 doc/Vorbis* /usr/share/doc/$direname
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
