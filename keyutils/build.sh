#!/bin/bash
set -e
name=keyutils
get_version() {
	local inst_ver=$(pkgver $name)
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/keyutils.git | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/keyutils.git/snapshot/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
make -j$(nproc)
sudo make NO_ARLIB=1 LIBDIR=/usr/lib BINDIR=/usr/bin SBINDIR=/usr/sbin install
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
