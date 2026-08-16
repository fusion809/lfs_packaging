#!/bin/bash
set -e
# Variable declarations
name=libaec
get_version() {
    local up_ver=$(wget -T 5 -cqO- "https://gitlab.dkrz.de/api/v4/projects/dkrz-sw%2Flibaec/repository/tags" | perl -nle 'while (m{"name":"v?([0-9.]+)"}g) { print $1 }' | sort -V | tail -n 1)
    ver_check "$up_ver" && return

    local arch_ver=$(aver $name)
    ver_check "$arch_ver" && return
}
version=$(get_version)
filename="$name-v$version.tar.bz2"
direname=${filename/.tar.bz2/}
depends=()
lfs_depends=(bash bzip2 coreutils glibc sed tar)
blfs_depends=(cmake wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.dkrz.de/k202009/libaec/-/archive/v$version/$name-v$version.tar.bz2
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
cmake -B build -S . \
    -DCMAKE_BUILD_TYPE=None \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -Wno-dev \
    -DBUILD_STATIC_LIBS=OFF
cmake --build build
sudo cmake --install build
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
