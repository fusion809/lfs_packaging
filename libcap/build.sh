#!/bin/bash
name=libcap
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2 | grep -E "$name-[0-9.]+" | cut -d '"' -f 2 | sed 's/.tar.*//g' | cut -d '-' -f 2 | sort -V | uniq | tail -n1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://git.kernel.org/pub/scm/libs/libcap/libcap.git/ | grep -E "refs/tags/v[0-9]+\.[0-9]+\.[0-9]+" | cut -d '/' -f 3 | sed -E 's/^v//g' | sort -V | sed -E 's/^1\.//g' | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
lfs_depends=(glibc gcc make tar xz openssl zlib zstd coreutils bash)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
sed -i '/install -m.*STA/d' libcap/Makefile
make prefix=/usr lib=lib -j$(nproc)
sudo make prefix=/usr lib=lib install
cd ..
echo $version > /var/lib/custom-packages/$name
