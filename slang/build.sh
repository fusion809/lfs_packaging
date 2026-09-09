#!/bin/bash
set -e
name=slang
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -cqO- -T 5 -t 1 https://www.jedsoft.org/releases/slang/ | grep -oE "slang-[0-9]+\.[0-9]+\.[0-9]+" | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(gcc glibc glslang spirv-tools)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.jedsoft.org/releases/slang/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr       \
            --sysconfdir=/etc   \
	    --with-readline=gnu)
cmi "${options[@]}"
make -j1 RPATH=
sudo su -c "make install_doc_dir=/usr/share/doc/$direname   \
     SLSH_DOC_DIR=/usr/share/doc/$direname/slsh \
     RPATH= install"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
