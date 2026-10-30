#!/bin/bash
set -e
name=mumps
get_version() {
	local up_ver=$(wget -c https://mumps-solver.org/index.php -qO- | grep "dwnld" | grep "[0-9.]+" -oE | grep "[0-9]")
	local inst_ver=$(pkgver $name)
	local aur_ver=$(aurver $name)
	ver_check "$up_ver" "$inst_ver" "$aur_ver" && return
	fver "$name" "$inst_ver"
}
_name=MUMPS
homepage="https://mumps-solver.org/"
description="Sparse solver library using Gaussian elimination."
version=$(get_version)
filename="${_name}_$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(bzip2 blas-lapack metis openmpi scalapack scotch zlib gcc)
download_src "https://mumps-solver.org/$filename"
unpk_enter "$filename" "$direname"
wget -c "https://aur.archlinux.org/cgit/aur.git/plain/Makefile.inc?h=mumps" -O Makefile.inc
sed -i -e "s|-Dmetis ||g" Makefile.inc
make all
sudo cp -r include/*.h /usr/include
sudo cp -r lib/*.so /usr/lib
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
