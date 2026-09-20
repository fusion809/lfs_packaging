#!/bin/bash
set -e
# Variable declarations
name=libaec
repo=Deutsches-Klimarechenzentrum/$name
get_version() {
    local up_ver=$(wget -T 5 -t 1 -cqO- "https://gitlab.dkrz.de/api/v4/projects/dkrz-sw%2Flibaec/repository/tags" | perl -nle 'while (m{"name":"v?([0-9.]+)"}g) { print $1 }' | sort -V | tail -n 1)
    local inst_ver=$(pkgver $name)
    ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
    local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/Deutsches-Klimarechenzentrum/libaec.git 2>/dev/null | grep -E "refs/tags/v[0-9.]+" | cut -d '/' -f 3 | sed 's/^v//g' | sort -V | tail -n 1)
    ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
    local vat_ver=$(vatver $name)
    ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

    local arch_ver=$(aver $name)
    ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
    fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$name-$version.tar.gz"
direname=${filename/.tar.*/}
depends=(bash bzip2 cmake coreutils glibc sed tar wget)
# Fetch and unpack source
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
cmake_options=(
    -DCMAKE_BUILD_TYPE=None \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -Wno-dev \
    -DBUILD_STATIC_LIBS=OFF
)
cmaki "${cmake_options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
