#!/bin/bash
set -e
# Variable declarations
name=gl2ps
get_version() {
	local up_ver=$(wget -T 5 -cqO- https://geuz.org/gl2ps/src/ | grep "[0-9].tgz" | grep -v "alpha\|beta\|\.rc" | cut -d '"' -f 8 | tail -n 1 | sed 's/gl2ps-//g' | sed 's/.tgz//g')
	ver_check "$up_ver" && return

	local git_ver=$(git ls-remote --tags --refs https://gitlab.onelab.info/gl2ps/gl2ps.git | grep "gl2ps_" | tail -n 1 | cut -d '/' -f 3 | sed 's/gl2ps_//g' | tr '_' '.')
	ver_check "$git_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" && return
}

version=$(get_version)

filename="$name-$version.tgz"
direname=${filename/.tgz/}
depends=()
lfs_depends=(bash coreutils gcc glibc gzip make sed tar)
blfs_depends=(cmake)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://geuz.org/gl2ps/src/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
mkdir build
cd build
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
export FORCE_SOURCE_DATE=1 # make pdftex adhere to SOURCE_DATE_EPOCH
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_EXE_LINKER_FLAGS=-lm \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5
make -j$(nproc)
sudo make install
# Cleanup and add to database
cd ../..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
