#!/bin/bash
# This builds from the latest git commit as the latest tagged release, 1.1.0,
# is too old for GNU Octave to be able to use its version of prettywriter.
pkgname=rapidjson
if ! which wget &> /dev/null; then
	echo "wget not found and used for downloading sources"
	exit
fi

if ! which cmake &> /dev/null; then
	echo "cmake not found and used for compiling"
	exit
fi

if ! which patch &> /dev/null; then
	echo "patch not found and used as part of the build process."
	exit
fi

if ! which make &> /dev/null; then
	echo "make not found and used as part of the build process."
	exit
fi
git clone https://github.com/Tencent/rapidjson
#wget -c https://github.com/Tencent/rapidjson/commit/3b2441b8.patch
cd $pkgname
pkgver=$(git log | head -n 1 | cut -d ' ' -f 2)
find -name CMakeLists.txt | xargs sed -e 's|-Werror||' -i # Don't use -Werror
  #patch -p1 -i ../3b2441b8.patch # Fix build with GCC 14
mkdir -p build
  cd build

  cmake \
      -DCMAKE_BUILD_TYPE=None \
      -DCMAKE_INSTALL_PREFIX:PATH=/usr \
      -DRAPIDJSON_HAS_STDSTRING=ON \
      -DRAPIDJSON_BUILD_CXX11=ON \
      -DRAPIDJSON_ENABLE_INSTRUMENTATION_OPT=OFF \
      -DDOC_INSTALL_DIR=/usr/share/doc/${pkgname}-$pkgver \
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
      ..

  make -j$(nproc)
  sudo make install


