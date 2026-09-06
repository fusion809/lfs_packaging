#!/bin/bash
set -e
name=lmdb
get_version() {
  local inst_ver=$(pkgver $name)
  local git_ver=$(timeout 15 git ls-remote --tags --refs https://git.openldap.org/openldap/openldap.git 'refs/tags/LMDB_*' | grep -oE "refs/tags/LMDB_[0-9.]+$" | sed 's/.*LMDB_//g' | sort -V | tail -n 1)
  ver_check "$git_ver" "$inst_ver" && return
  local arch_ver=$(aver $name)
  ver_check "$arch_ver" "$inst_ver" && return
  local lfs_vers=$(lfs_ver $name)
  ver_check "$lfs_vers" "$inst_ver" && return
  fver "$name" "$inst_ver"
}
version=$(get_version)
filename="openldap-LMDB_$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://git.openldap.org/openldap/openldap/-/archive/LMDB_$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cd libraries/liblmdb
make -j$(nproc)
sed -i 's| liblmdb.a||' Makefile
sudo make prefix=/usr install
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
