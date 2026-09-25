#!/bin/bash
set -e
name=lmdb
homepage="https://symas.com/lmdb/"
url="https://git.openldap.org/openldap/openldap"
get_version() {
  local inst_ver=$(pkgver $name)
  local lfs_vers=$(lfs_ver $name)
  local git_ver=$(timeout 15 git ls-remote --tags --refs $url.git 'refs/tags/LMDB_*' | grep -oE "refs/tags/LMDB_[0-9.]+$" | sed 's/.*LMDB_//g' | sort -V | tail -n 1)
  ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
  local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
  local vat_ver=$(vatver $name)
  ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

  local arch_ver=$(aver $name)
  ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
  fver "$name" "$inst_ver"
}
version=$(get_version)
filename="openldap-LMDB_$version.tar.bz2"
direname="${filename/.tar.*/}"
download_src "$url/-/archive/LMDB_$version/$filename"
unpk_enter "$filename" "$direname"
cd libraries/liblmdb
make -j$(nproc)
sed -i 's| liblmdb.a||' Makefile
sudo make prefix=/usr install
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
