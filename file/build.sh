#!/bin/bash
name=file
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://astron.com/pub/file/ | grep -E "file-[0-9.]+" | cut -d '"' -f 2 | sed 's/.tar.gz//g' | cut -d '-' -f 2 | grep -E "^[0-9.]+$" | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/file/file.git | grep "refs/tags/FILE" | sed 's/.*FILE//g' | tr '_' '.' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(bzip2 glibc xz zstd)
blfs_depends=(libseccomp)
lfs_depends=(zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://astron.com/pub/$name/$filename
fi

rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr
cd ..
echo "$version" > /var/lib/custom-packages/$name
