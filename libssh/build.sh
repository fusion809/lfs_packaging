#!/bin/bash
name=libssh
maj_ver=$(wget -cqO- https://www.libssh.org/files/ | grep -E "[0-9.]+/" | cut -d '"' -f 8 | cut -d '/' -f 1 | sort -V | tail -n 1)
get_version() {
	local up_ver=$(wget -cqO- https://www.libssh.org/files/$maj_ver/ | grep -E "[0-9.]+.tar.xz\"" | cut -d '-' -f 2 | sed 's/.tar.xz.*//g' | sort -V | tail -n 1)
	local inst_ver=$(pkgver $name)
	#ver_check $up_ver $inst_ver && return
	echo "$up_ver"
	local arch_ver=$(aver $name)
	#ver_check $arch_ver $inst_ver && return
}	
version=$(get_version)
depends=(mitkrb)
blfs_depends=(keyutils)
lfs_depends=(e2fsprogs glibc openssl zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.libssh.org/files/$maj_ver/$filename
fi

rm -rf $direname
tar xf $filename
cd $direname
cmaki -D CMAKE_INSTALL_PREFIX=/usr
cd ..
#rm -rf $direname $filename
echo "$version" > /var/lib/custom-packages/$name
