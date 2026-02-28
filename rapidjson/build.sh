#!/bin/bash
# This builds from the latest git commit as the latest tagged release, 1.1.0,
# is too old for GNU Octave to be able to use its version of prettywriter.
set -e
depends=()
NAME=rapidjson
source check-deps.sh
if ! [[ -d rapidjson ]]; then
	git clone https://github.com/Tencent/rapidjson
fi
cd $NAME
git pull origin master
VERSION=$(git log | head -n 1 | cut -d ' ' -f 2)
find -name CMakeLists.txt | xargs sed -e 's|-Werror||' -i # Don't use -Werror
mkdir -p build
cd build
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
cmake \
      -DCMAKE_BUILD_TYPE=None \
      -DCMAKE_INSTALL_PREFIX:PATH=/usr \
      -DRAPIDJSON_HAS_STDSTRING=ON \
      -DRAPIDJSON_BUILD_CXX11=ON \
      -DRAPIDJSON_ENABLE_INSTRUMENTATION_OPT=OFF \
      -DDOC_INSTALL_DIR=/usr/share/doc/${NAME}-$VERSION \
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	  -DCMAKE_C_FLAGS="$CFLAGS" \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
      ..

make -j$(nproc)
sudo make install
cd ..
rm -rf build
cd ..
