#!/bin/bash
set -e
pkgbase=openmpi
VERSION=$(wget -cqO- https://www-lb.open-mpi.org/software/ompi/ | grep ".tar.gz" | head -n 1 | cut -d '"' -f 2 | cut -d '/' -f 7 | sed 's/.tar.gz//g' | sed 's/openmpi-//g')
filename="$pkgbase-$VERSION.tar.bz2"
direname="${filename/.tar.bz2/}"
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://www.open-mpi.org/software/ompi/v${VERSION%.*}/downloads/$filename
fi
tar xf $filename
cd $direname
sed -i 's|WRAPPER__FCFLAGS|WRAPPER_FCFLAGS|g' configure
  sed -i 's|WRAPPER_EXTRA_FCFLAGS|WRAPPER_FCFLAGS|g' configure
  sed -i 's|"-I/usr/include",||' opal/tools/wrappers/opal_wrapper.c
local configure_options=(
    --prefix=/usr
    --enable-builtin-atomics
    --enable-memchecker
    --enable-mpi-fortran=all
    --enable-pretty-print-stacktrace
    --libdir=/usr/lib
    --sysconfdir=/etc/$pkgbase
    --with-hwloc=external
    --with-libevent=external
    --with-pmix=external
    --with-prrte=external
    --with-valgrind
    #--with-ucc=/usr
    #--with-ucx=/usr
    # this tricks the configure script to look for /usr/lib/pkgconfig/cuda.pc
    # instead of /opt/cuda/lib/pkgconfig/cuda.pc
    #--with-rocm=/opt/rocm
    # all components that link to libraries provided by optdepends must be run-time loadable
    --enable-mca-dso=accelerator_cuda,accelerator_rocm,btl_smcuda,rcache_gpusm,rcache_rgpusm,coll_ucc,scoll_ucc
    # mpirun should not warn on MCA component load failures by default - usually caused by missing optdepends, which is ok
    # https://docs.open-mpi.org/en/main/installing-open-mpi/configure-cli-options/installation.html
    #--with-show-load-errors='^accelerator,rcache,coll/ucc'
  )
export HOSTNAME=buildhost
export USER=builduser

./configure "${configure_options[@]}"
# prevent excessive overlinking due to libtool
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
make V=1 -j$(nproc)
sudo make install
cd ..
rm -rf ${filename} $direname
