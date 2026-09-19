#!/bin/bash
set -e
name=libssh
maj_ver=$(wget -cqO- https://www.libssh.org/files/ | grep -E "[0-9.]+/" | cut -d '"' -f 8 | cut -d '/' -f 1 | sort -V | tail -n 1)
get_version() {
	local up_ver=$(wget -cqO- https://www.libssh.org/files/$maj_ver/ | grep -E "[0-9.]+.tar.xz\"" | cut -d '-' -f 2 | sed 's/.tar.xz.*//g' | sort -V | tail -n 1)
	local inst_ver=$(pkgver $name)
	ver_check $up_ver $inst_ver && return
	echo "$up_ver"
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check $arch_ver $inst_ver && return
	fver "$name" "$inst_ver"
}	
version=$(get_version)
depends=(e2fsprogs glibc keyutils mitkrb openssl zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
download_src "https://www.libssh.org/files/$maj_ver/$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr
cd ../..
#rm -rf $direname $filename
echo "$version" | sudo tee /var/lib/custom-packages/$name
