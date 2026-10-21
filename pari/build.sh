#!/bin/bash
set -e
name=pari
get_version() {
	local git_ver=$(git ls-remote --tags --refs https://pari.math.u-bordeaux.fr/git/pari.git | grep "pari-[0-9]+\.[0-9]+\.[0-9]+" -oE | cut -d '-' -f 2 | sort -V | tail -n 1)
	local inst_ver=$(pkgver $name)
	local arch_ver=$(aver $name)
	ver_check "$git_ver" "$inst_ver" "$arch_ver" && return
	local up_ver=$(wget -cqO- -T 5 -t 1 https://pari.math.u-bordeaux.fr/download.html | grep "Stable" | grep ".tar.gz" | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)
	ver_check "$up_ver" "$inst_ver" "$arch_ver" && return
	fver "$name" "$inst_ver"
}
homepage="https://pari.math.u-bordeaux.fr/"
description="Cross-platform CAS."
version=$(get_version)
download_git "https://pari.math.u-bordeaux.fr/git/pari.git"
cd pari
git checkout $name-$version
sed -e 's|DLLDFLAGS  = \$DLLDFLAGS|DLLDFLAGS  = $DLLDFLAGS $LDFLAGS|' -i config/Makefile.SH # Honor system LDFLAGS

  git show 603d02feac84d67c92688cbd60e366ee19776492 -- src/basemath/ZX.c | git apply - # Fix segfault in hyperellcharpoly
  git show 6fcdb19f551b5695a13c2ea8ec05796629dcc546 -- src/basemath/alglin3.c | git apply - # Fix float
./Configure --prefix=/usr --with-readline --mt=pthread --with-gmp
make -j$(nproc) all
make -C Olinux-x86_64 gp-sta -j$(nproc)
sudo make install
sudo make -C Olinux-x86_64 install-bin-sta
cd ../
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
