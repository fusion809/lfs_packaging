#!/bin/bash
set -e
# Variable declarations
name="arpack"
_name="arpack-ng"
source ~/lfs_packaging/shared-funcs.sh
get_version() {
	local up_ver=$(wget -cqO- https://github.com/opencollab/arpack-ng/tags | grep ".tar.gz" | grep -v "alpha\|beta\|\.rc" | head -n 1 | cut -d '"' -f 4 | cut -d '/' -f 7 | sed 's/.tar.gz//g')
	if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$up_ver"
		return 0
	fi

	local git_ver=$(git ls-remote --tags --refs https://github.com/opencollab/arpack-ng | cut -d '/' -f 3 | sed 's/v//g' | tail -n 1)
	if echo "$git_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$git_ver"
		return 0
	fi

	local arch_ver=$(aver $name)
	if echo "$arch_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$arch_ver"
		return 0
	fi
}

version=$(get_version)
depends=(lapack openmpi)
lfs_depends=(bash coreutils gzip make sed tar)
blfs_depends=(gcc # Fortran support needed
wget)
filename="$_name-$version.tar.gz"
direname=${filename/.tar.gz/}
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/opencollab/arpack-ng/archive/$version.tar.gz -O $filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./bootstrap
./configure --enable-icb --enable-mpi --prefix=/usr
  make F77=mpif77 \
    CFLAGS+="-O2 -fPIC $(pkg-config --cflags ompi-f77) " \
    LIBS+=" $(pkg-config --libs ompi-f77) " -j$(nproc)
sudo make install
export DDIR=/tmp/custom_arpackdir
mkdir -p $DDIR
make install DESTDIR="$DDIR" || true
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
if [ -d "$DDIR" ] && [ "$(ls -A "$DDIR" 2>/dev/null)" ]; then
   find "$DDIR" -type f -o -type l | sed "s|^$DDIR||" | sudo tee -a "/var/lib/custom-packages/$name" > /dev/null
fi
sudo rm -rf $DDIR
