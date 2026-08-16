#!/bin/bash
set -e
# Variable declarations
name=qhull
get_version() {
    local up_ver=$(wget -T 5 -cqO- http://www.qhull.org/download/ | grep ".tgz\"" | grep -v "alpha\|beta\|\.rc" | sed 's/.*Download: Qhull //g' | sed 's/ for Unix.*//g')
    ver_check "$up_ver" && return

    local git_ver=$(git ls-remote --tags --refs https://github.com/qhull/qhull.git | grep "refs/tags/[0-9.]*$" | cut -d '/' -f 3 | sort -V | tail -n 1)
    ver_check "$git_ver" && return

    local arch_ver=$(aver $name)
    ver_check "$arch_ver" && return
}
get_alt_version() {
    local alt_ver=$(wget -T 5 -cqO- http://www.qhull.org/download/ | grep ".tgz\"" | grep -v "alpha\|beta\|\.rc" | cut -d '"' -f 2 | cut -d '/' -f 5 | cut -d '-' -f 4 | sed 's/.tgz//')
    ver_check "$alt_ver" && return
    local git_ver=$(git ls-remote --tags --refs https://github.com/qhull/qhull.git | grep "refs/tags/v[0-9.]*$" | cut -d '/' -f 3 | sed 's/^v//g' | sort -V | tail -n 1)
    ver_check "$git_ver" && return
}
version=$(get_version)
_version=$(get_alt_version)
filename="$name-${version%.*}-src-$_version.tgz"
direname="$name-$version"
depends=()
lfs_depends=(bash coreutils glibc gzip sed tar)
blfs_depends=(cmake wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c http://www.qhull.org/download/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
cmake -B build -S . \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_C_FLAGS="$CFLAGS -ffat-lto-objects" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS -ffat-lto-objects" \
    -DCMAKE_SKIP_RPATH=ON \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build build
cmake --build build --target libqhull
sudo cmake --install build
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
