#!/bin/bash
set -e
depends=(bash coreutils gcc glibc gmp gzip make sed tar)
name=glpk
version=$(gnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
gnu_download "$name" "$filename"
download_src "https://gitlab.archlinux.org/archlinux/packaging/packages/glpk/-/raw/main/gcc-15.patch?ref_type=heads&inline=false" "gcc-15.patch"
unpk_enter "$filename" "$direname"
patch -Np1 -i ../gcc-15.patch
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
sudo autoreconf -fiv
sudo chown $USER -R .
configure_options=(
	--prefix=/usr 
	--with-gmp
)
cmi "${configure_options[@]}"
cd ..
sudo rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
