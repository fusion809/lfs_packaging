#!/bin/bash
# This builds from the latest git commit as the latest tagged release, 1.1.0,
# is too old for GNU Octave to be able to use its version of prettywriter.
set -e
# Variable declarations
name=rapidjson
repo="Tencent/$name"
version=$(git ls-remote https://github.com/$repo.git HEAD | awk '{print $1}')
depends=()
lfs_depends=(bash coreutils make sed)
blfs_depends=(cmake git)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c "https://github.com/$repo/archive/$version.tar.gz" -O $filename
fi
rm -rf $direname
tar xf $filename
cd $direname
# Compile and install
find . -name CMakeLists.txt | xargs sed -e 's|-Werror||' -i # Don't use -Werror
CXXFLAGS="-O2 -fPIC"
cmake_options=(
      -DCMAKE_BUILD_TYPE=None \
      -DCMAKE_INSTALL_PREFIX:PATH=/usr \
      -DRAPIDJSON_HAS_STDSTRING=ON \
      -DRAPIDJSON_BUILD_CXX11=ON \
      -DRAPIDJSON_ENABLE_INSTRUMENTATION_OPT=OFF \
      -DDOC_INSTALL_DIR=/usr/share/doc/${name}-$version \
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
