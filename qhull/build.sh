#!/bin/bash
set -e
# Variable declarations
name=qhull
get_version() {
    local inst_ver=$(pkgver $name)
    local art_ver=$(artver $name)
    local up_ver=$(wget -T 5 -cqO- http://www.qhull.org/download/ | grep ".tgz\"" | grep -v "alpha\|beta\|\.rc" | sed 's/.*Download: Qhull //g' | sed 's/ for Unix.*//g')
    ver_check "$up_ver" "$inst_ver" "$art_ver" && return

    local git_ver=$(git ls-remote --tags --refs https://github.com/qhull/qhull.git | grep "refs/tags/[0-9.]*$" | cut -d '/' -f 3 | sort -V | tail -n 1)
    ver_check "$git_ver" "$inst_ver" "$art_ver" && return
    local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return

    local vat_ver=$(vatver $name)
    ver_check "$vat_ver" "$inst_ver" "$art_ver" && return

    local arch_ver=$(aver $name)
    ver_check "$arch_ver" "$inst_ver" "$art_ver" && return

    fver "$name" "$inst_ver"
}
get_alt_version() {
    local inst_ver=$(pkgver $name 2)
    local alt_ver=$(wget -T 5 -cqO- http://www.qhull.org/download/ | grep ".tgz\"" | grep -v "alpha\|beta\|\.rc" | cut -d '"' -f 2 | cut -d '/' -f 5 | cut -d '-' -f 4 | sed 's/.tgz//')
    ver_check "$alt_ver" "$inst_ver" "$art_ver" && return
    local git_ver=$(git ls-remote --tags --refs https://github.com/qhull/qhull.git | grep "refs/tags/v[0-9.]*$" | cut -d '/' -f 3 | sed 's/^v//g' | sort -V | tail -n 1)
    ver_check "$git_ver" "$inst_ver" "$art_ver" && return
    local arch_ver=$(aver $name 2)
    ver_check "$arch_ver" "$inst_ver" "$art_ver" && return
    fver "$name" "$inst_ver"
}
version=$(get_version)
_version=$(get_alt_version)
filename="$name-${version%.*}-src-$_version.tgz"
direname="$name-$version"
depends=(bash cmake coreutils glibc gzip sed tar wget)
# Fetch and unpack source
download_src "http://www.qhull.org/download/$filename"
unpk_enter "$filename" "$direname"
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
cmake_options=(
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_C_FLAGS="$CFLAGS -ffat-lto-objects" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS -ffat-lto-objects" \
    -DCMAKE_SKIP_RPATH=ON \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
)
cmaki "${cmake_options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
echo "$_version" | sudo tee -a /var/lib/custom-packages/$name
