#!/bin/bash
set -e
depends=()
NAME=gl2ps
VERSION=$(wget -cqO- https://geuz.org/gl2ps/src/ | grep "[0-9].tgz" | cut -d '"' -f 8 | tail -n 1 | sed 's/gl2ps-//g' | sed 's/.tgz//g')
filename="$NAME-$VERSION.tgz"
if ! [[ -f $filename ]]; then
	wget -c https://geuz.org/gl2ps/src/$filename
fi
direname=${filename/.tgz/}
rm -rf $direname
tar xf $filename
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
cd ../..
sudo rm -rf $filename $direname
echo $VERSION > /var/lib/lfs-custom-packages/$NAME
