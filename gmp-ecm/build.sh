#!/bin/bash
set -e
name=gmp-ecm
get_version() {
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://gitlab.inria.fr/zimmerma/ecm.git | grep "refs/tags/git-[0-9.]+" -oE | cut -d '-' -f 2 | sort -V | tail -n 1)
	local arch_ver=$(aver $name)
	local inst_ver=$(pkgver $name)
	ver_check "$git_ver" "$inst_ver" "$arch_ver" && return
	fver "$name" "$inst_ver"
}
homepage="https://github.com/sethtroisi/gmp-ecm"
description="Elliptic curve method for integer factorization."
version=$(get_version)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
#gha_download "$repo" "$version" "$filename"
download_git "https://gitlab.inria.fr/zimmerma/ecm"
#unpk_enter "$filename" "$direname"
cd ecm
git checkout git-$version
sudo autoreconf -fiv
sudo chown $USER -R .
cmi --prefix=/usr --disable-static --enable-shared --enable-openmp
cd ../
#rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
