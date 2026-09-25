#!/bin/bash
set -e
name=slang
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -cqO- -T 5 -t 1 https://www.jedsoft.org/releases/slang/ | grep -oE "slang-[0-9]+\.[0-9]+\.[0-9]+" | cut -d '-' -f 2 | sort -V | tail -n 1)
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
depends=(gcc glibc glslang spirv-tools)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
download_src "https://www.jedsoft.org/releases/slang/$filename"
unpk_enter "$filename" "$direname"
options=(
	--prefix=/usr       \
    --sysconfdir=/etc   \
	--with-readline=gnu
)
cmi "${options[@]}"
make -j1 RPATH=
sudo su -c "make install_doc_dir=/usr/share/doc/$direname   \
     SLSH_DOC_DIR=/usr/share/doc/$direname/slsh \
     RPATH= install"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
