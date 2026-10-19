#!/bin/bash
set -e
name=netcdf-cxx
repo=Unidata/${name}4
homepage="https://github.com/Unidata/netcdf-cxx4/"
description="NetCDF C++ bindings."
version=$(gh_ver $repo)
depends=(gcc netcdf curl)
filename="${name}4-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
wget -c https://github.com/Unidata/netcdf-cxx4/commit/fe9511b4149fd6e7f71252f61657e03ce6ee01c6.patch -O upstream.patch
patch -Np1 -i upstream.patch
sudo autoreconf -fiv
sudo chown $USER -R .
export CXXFLAGS="${CXXFLAGS} -lnetcdf"
cmi --prefix=/usr --enable-shared --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
