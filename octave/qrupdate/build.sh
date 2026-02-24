#!/bin/bash
NAME=qrupdate
VERSION=$(wget -cqO- https://github.com/mpimd-csc/qrupdate-ng/releases | grep "releases/tag/v" | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
filename=$NAME-$VERSION.tar.gz
wget -c https://github.com/mpimd-csc/qrupdate-ng/archive/v$VERSION.tar.gz -O $filename
rm -rf $NAME-ng-$VERSION
tar xf $filename
cd ${NAME}-ng-$VERSION
cmake -B build -S . \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
  cmake --build build --verbose
  sudo cmake --install build
