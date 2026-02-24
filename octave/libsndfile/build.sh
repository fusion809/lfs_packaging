#!/bin/bash
NAME=libsndfile
VERSION=$(wget -cqO- https://github.com/libsndfile/libsndfile/releases | grep "releases/tag/[0-9]" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6)
filename="$NAME-$VERSION.tar.xz"
rm -rf ${filename/.tar.xz/}
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$NAME/$NAME/releases/download/$VERSION/$filename
fi
if [[ $VERSION == "1.2.2" ]]; then
	wget -c https://github.com/libsndfile/libsndfile/commit/0754562e13d2e63a248a1c82f90b30bc0ffe307c.patch -O $NAME-$VERSION-CVE-2022-33065.patch
fi
tar xf $filename
cd ${filename/.tar.xz/}
if [[ $VERSION == "1.2.2" ]]; then
	patch -Np1 -i ../$NAME-1.2.2-CVE-2022-33065.patch
fi
 cmake_options=(
    -B build
    -D BUILD_SHARED_LIBS=ON
    -D CMAKE_INSTALL_PREFIX=/usr
    -D CMAKE_BUILD_TYPE=None
    -D CMAKE_POLICY_VERSION_MINIMUM=3.5
    -D ENABLE_EXTERNAL_LIBS=ON
    -D ENABLE_MPEG=ON
    -S .
    -W no-dev
  )

  cmake "${cmake_options[@]}"
  cmake --build build --verbose
 sudo cmake --install build
  sudo install -vDm 644 {AUTHORS,ChangeLog,README} -t "/usr/share/doc/$NAME-$VERSION"

