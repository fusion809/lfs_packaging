#!/bin/bash
set -e
# Variable declarations
name=openmpi
get_version() {
  local up_ver=$(wget -T 5 -cqO- https://www-lb.open-mpi.org/software/ompi/ | grep ".tar.gz" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 2 | cut -d '/' -f 7 | sed 's/.tar.gz//g' | sed 's/openmpi-//g')
  ver_check "$up_ver" && return
  local git_ver=$(git ls-remote --tags --refs https://github.com/open-mpi/ompi.git | grep "refs/tags/v[0-9.]*$" | cut -d '/' -f 3 | sed 's/^v//g' | sort -V | tail -n 1)
  ver_check "$git_ver" && return
  local arch_ver=$(aver $name)
  ver_check "$arch_ver" && return
}
version=$(get_version)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
depends=(hwloc libfabric numactl openpmix prrte)
lfs_depends=(bash bzip2 coreutils gcc glibc make sed systemd tar)
blfs_depends=(gcc libevent valgrind)
# Dependencies useful depending on your hardware include:
hardware_depends=(cuda
nvidia #libcuda.so needed
hip-runtime-amd)
# Communication frameworks. Not strictly required, but may be useful for better performance
optional_depends=(openucc
openucx)
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://www.open-mpi.org/software/ompi/v${version%.*}/downloads/$filename
fi
tar xf $filename
cd $direname
sed -i 's|WRAPPER__FCFLAGS|WRAPPER_FCFLAGS|g' configure
  sed -i 's|WRAPPER_EXTRA_FCFLAGS|WRAPPER_FCFLAGS|g' configure
  sed -i 's|"-I/usr/include",||' opal/tools/wrappers/opal_wrapper.c
configure_options=(
    --prefix=/usr
    --enable-builtin-atomics
    --enable-memchecker
    --enable-mpi-fortran=all
    --enable-pretty-print-stacktrace
    --libdir=/usr/lib
    --sysconfdir=/etc/$name
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
# Cleanup and add to database
cd ..
sudo rm -rf ${filename} $direname
echo $version > /var/lib/custom-packages/$name
