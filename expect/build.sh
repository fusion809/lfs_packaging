#!/bin/bash
# Build currently fails due to tcl9.0.4 issues
set -e
name=expect
description="A tool for automating interactive applications"
homepage="https://sourceforge.net/projects/expect/"
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- ${homepage}/files/Expect/ | grep -E "title=\"[0-9]+\.[0-9]+"  | cut -d '"' -f 2 | sort -V | tail -n 1)
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
depends=(tcl)
filename="${name}${version}.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://prdownloads.sourceforge.net/$name/$filename"
unpk_enter "$filename" "$direname"
gap_patches $name
configure_options=(
	--prefix=/usr           \
    --with-tcl=/usr/lib     \
    --enable-shared         \
    --disable-rpath         \
    --mandir=/usr/share/man \
	--with-tclinclude=/usr/include)
cmi "${configure_options[@]}"
sudo ln -svf expect${version}/libexpect${version}.so /usr/lib
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
