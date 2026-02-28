#!/bin/bash
set -e
NAME=gl2ps
VERSION=$(wget -cqO- https://geuz.org/gl2ps/src/ | grep "[0-9].tgz" | cut -d '"' -f 8 | tail -n 1 | sed 's/gl2ps-//g' | sed 's/.tgz//g')
if ! [[ -f gl2ps-${VERSION}.tgz ]]; then
	wget -c https://geuz.org/gl2ps/src/gl2ps-${VERSION}.tgz
fi
tar xf $NAME-$VERSION.tgz
cd $NAME-$VERSION
mkdir build
cd build
export FORCE_SOURCE_DATE=1 # make pdftex adhere to SOURCE_DATE_EPOCH
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_EXE_LINKER_FLAGS=-lm \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5
make -j$(nproc)
sudo make install
cd ../..
rm -rf $NAME-$VERSION*
