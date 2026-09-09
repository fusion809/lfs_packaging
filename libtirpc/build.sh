#!/bin/bash
set -e
name=libtirpc
get_version() {
	local inst_ver=$(pkgver $name)
	local git_ver=$(timeout 5 git ls-remote --tags --refs git://linux-nfs.org/~steved/libtirpc.git | grep "libtirpc-[0-9-]+$" -oE | sed 's/libtirpc-//g' | sed 's/-/./g' | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(glibc)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://downloads.sourceforge.net/libtirpc/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --disable-static --disable-gssapi --sysconfdir=/etc
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
