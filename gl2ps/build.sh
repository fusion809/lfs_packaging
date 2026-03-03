#!/bin/bash
set -e
# Variable declarations
name=gl2ps
version=$(wget -cqO- https://geuz.org/gl2ps/src/ | grep "[0-9].tgz" | grep -v "alpha\|beta\|rc" | cut -d '"' -f 8 | tail -n 1 | sed 's/gl2ps-//g' | sed 's/.tgz//g')
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
  -DCMAKE_POLICY_version_MINIMUM=3.5
make -j$(nproc)
sudo make install
# Cleanup and add to database
cd ../..
sudo rm -rf $filename $direname
echo $version > /var/lib/lfs-custom-packages/$name
