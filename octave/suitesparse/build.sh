#!/bin/bash
NAME=SuiteSparse
VERSION=$(wget -cqO- https://github.com/DrTimothyAldenDavis/SuiteSparse/releases | grep "releases/tag/v" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
filename="$NAME-$VERSION.tar.gz"
wget -c https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v$VERSION.tar.gz -O $filename
rm -rf ${filename/.tar.gz/}
tar xf $filename
cd ${filename/.tar.gz/}
CMAKE_OPTIONS="-DBLA_VENDOR=Generic \
                 -DCMAKE_INSTALL_PREFIX=/usr \
                 -DCMAKE_BUILD_TYPE=None \
                 -DNSTATIC=ON" \
  make -j$(nproc)
sudo make install
