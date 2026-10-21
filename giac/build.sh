#!/bin/bash
set -e
name=giac
get_version() {
	local up_ver=$(wget -cqO- -T 5 -t 1 https://www-fourier.univ-grenoble-alpes.fr/~parisse/giac.html | grep "version [0-9]+\.[0-9]+\.[0-9]+-[0-9]+" -oE | cut -d ' ' -f 2 | head -n 1)
	local arch_ver=$(aver $name)
	local inst_ver=$(pkgver $name)
	ver_check "$up_ver" "$inst_ver" "$arch_ver" && return
	fver "$name" "$inst_ver"
}
homepage="https://www-fourier.univ-grenoble-alpes.fr/~parisse/giac.html"
description="Open-source computer algebra system"
version=$(get_version)
filename="${name}_$version.tar.gz"
direname="$name-${version/-*/}"
download_src "https://www-fourier.univ-grenoble-alpes.fr/~parisse/debian/dists/stable/main/source/$filename"
unpk_enter "$filename" "$direname"
wget -c "https://gitlab.archlinux.org/archlinux/packaging/packages/giac/-/raw/main/pari-2.19.patch" -O giac.patch
patch -Np1 -i giac.patch
export CFLAGS="${CFLAGS/_FORTIFY_SOURCE=3/_FORTIFY_SOURCE=2}"
  export CXXFLAGS="${CXXFLAGS/_FORTIFY_SOURCE=3/_FORTIFY_SOURCE=2}"

  CXXFLAGS+=" -Wp,-U_GLIBCXX_ASSERTIONS" # Fix crashes
  CXXFLAGS+=" -I/usr/include/cairo"
./configure --prefix=/usr --disable-static
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
make -j$(nproc)
sudo make install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
