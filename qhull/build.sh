#!/bin/bash
set -e
# Variable declarations
name=qhull
get_version() {
    local up_ver=$(wget -T 5 -cqO- http://www.qhull.org/download/ | grep ".tgz\"" | grep -v "alpha\|beta\|\.rc" | sed 's/.*Download: Qhull //g' | sed 's/ for Unix.*//g')
    if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
        echo "$up_ver"
        return 0
    fi

    local git_ver=$(git ls-remote --tags --refs https://github.com/qhull/qhull.git | grep "refs/tags/[0-9.]*$" | cut -d '/' -f 3 | sort -V | tail -n 1)
    if echo "$git_ver" | grep -q "[0-9]\.[0-9]"; then
        echo "$git_ver"
        return 0
    fi

    local arch_ver=$(aver $name)
    if echo "$arch_ver" | grep -q "[0-9]\.[0-9]"; then
        echo "$arch_ver"
        return 0
    fi
}
get_alt_version() {
    local alt_ver=$(wget -T 5 -cqO- http://www.qhull.org/download/ | grep ".tgz\"" | grep -v "alpha\|beta\|\.rc" | cut -d '"' -f 2 | cut -d '/' -f 5 | cut -d '-' -f 4 | sed 's/.tgz//')
    if echo "$alt_ver" | grep -q "[0-9]\.[0-9]"; then
        echo "$alt_ver"
        return 0
    fi
    local git_ver=$(git ls-remote --tags --refs https://github.com/qhull/qhull.git | grep "refs/tags/v[0-9.]*$" | cut -d '/' -f 3 | sed 's/^v//g' | sort -V | tail -n 1)
    if echo "$git_ver" | grep -q "[0-9]\.[0-9]"; then
        echo "$git_ver"
        return 0
    fi
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
