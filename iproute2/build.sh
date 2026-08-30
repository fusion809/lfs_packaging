#!/bin/bash
name=iproute2
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://www.kernel.org/pub/linux/utils/net/iproute2/ | grep -E "iproute2-[0-9]+\.[0-9]+\.[0-9]+" | cut -d '"' -f 2 | sed 's/.tar.*//g' | cut -d '-' -f 2 | sort -V | uniq | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs git://git.kernel.org/pub/scm/network/iproute2/iproute2.git | grep -E "refs/tags/v[0-9]+\.[0-9]+\.[0-9]+" | cut -d '/' -f 3 | sed 's/^v//g' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
lfs_depends=(bash coreutils gcc glibc libcap libelf make tar xz)
blfs_depends=(iptables libtirpc)
depends=(bzip2 glibc xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.kernel.org/pub/linux/utils/net/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
make NETNS_RUN_DIR=/run/netns
sudo make SBINDIR=/usr/sbin install
sudo install -vDm644 COPYING README* -t /usr/share/doc/$direname
cd ..
echo $version > /var/lib/custom-packages/$name
