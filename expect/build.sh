#!/bin/bash
set -e
name=expect
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 2 -t 1 -cqO- https://sourceforge.net/projects/expect/files/Expect/ | grep -E "title=\"[0-9]+\.[0-9]+"  | cut -d '"' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
lfs_depends=(tcl)
filename="${name}${version}.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://prdownloads.sourceforge.net/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
gap_patches $name
configure_options=(--prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --disable-rpath         \
            --mandir=/usr/share/man \
	    --with-tclinclude=/usr/include)
cmi "${configure_options[@]}"
sudo ln -svf expect${version}/libexpect${version}.so /usr/lib
cd ..
rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
