#!/bin/bash
set -e
# Variable declarations
name=lzip
homepage="https://www.nongnu.org/lzip"
url="https://download.savannah.gnu.org/releases/$name"
# Get versions into temp variables (updates will include these because they are ABOVE the version= line)
get_version() {
  local inst_ver=$(pkgver $name)
  local up_ver=$(wget -cqO- -T 5 "$url" | grep -oE '$name-[0-9.]+\.tar\.gz' | sort -V | tail -n 1 | sed -e "s/$name-//" -e 's/.tar.gz//')
  ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
  local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
  local vat_ver=$(vatver $name)
  ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

  local arch_ver=$(aver $name)
  ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
  fver "$name" "$inst_ver"
}

version=$(get_version)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(bash coreutils gcc glibc gzip make sed tar wget)
src="$url/$filename"
# Fetch and unpack source
download_src "$src"
unpk_enter "$filename" "$direname"
# Compile and install
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
cmi --prefix=/usr
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
