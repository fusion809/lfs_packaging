#!/bin/bash
set -e
# Variable declarations
name="arpack"
_name="arpack-ng"
repo="opencollab/arpack-ng"
version=$(gh_ver $repo)
depends=(bash coreutils gcc gcc glibc gzip hwloc lapack libevent libfabric make numactl openmpi openpmix sed systemd tar wget)
filename="$_name-$version.tar.gz"
direname=${filename/.tar.gz/}
# Fetch and unpack source
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
sudo ./bootstrap
sudo chown $USER -R .
./configure --enable-icb --enable-mpi --prefix=/usr
  make F77=mpif77 \
    CFLAGS+="-O2 -fPIC $(pkg-config --cflags ompi-f77) " \
    LIBS+=" $(pkg-config --libs ompi-f77) " -j$(nproc)
sudo make install
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
