#!/bin/bash
set -e
name=file
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://astron.com/pub/file/ | grep -E "file-[0-9.]+" | cut -d '"' -f 2 | sed 's/.tar.gz//g' | cut -d '-' -f 2 | grep -E "^[0-9.]+$" | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/file/file.git | grep "refs/tags/FILE" | sed 's/.*FILE//g' | tr '_' '.' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(bzip2 glibc libseccomp xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://astron.com/pub/$name/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
cd ..
echo "$version" | sudo tee /var/lib/custom-packages/$name
