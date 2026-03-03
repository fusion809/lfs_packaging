#!/bin/bash
set -e
# Variable declarations
name=pcre2
version=$(wget -cqO- https://github.com/PCRE2Project/pcre2/releases | grep "releases/tag/pcre2" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 6 | cut -d '=' -f 3 | cut -d '/' -f 6 | sed 's/pcre2-//g')
filename="$name-$version.tar.gz"
direname="$name-$name-$version"
depends=()
lfs_depends=(bash bzip2 coreutils glibc gzip make readline sed tar)
blfs_depends=(wget)
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://github.com/PCRE2Project/pcre2/archive/$filename
fi
if ! [[ -f sljit-master.tar.gz ]]; then
	wget -c https://github.com/zherczeg/sljit/archive/master.tar.gz -O sljit-master.tar.gz
fi
tar xf $filename
cd $direname
rm -rf deps/sljit
tar xf ../sljit-master.tar.gz
mv sljit-master sljit 
mv sljit deps/sljit
# Compile and install
./autogen.sh
configure_options=(
    --enable-jit
    --enable-pcre2-16
    --enable-pcre2-32
    --enable-pcre2grep-libbz2
    --enable-pcre2grep-libz
    --enable-pcre2test-libreadline
    --prefix=/usr
  )
CFLAGS+="-O2 -fPIC -ffat-lto-objects"
CXXFLAGS+="-O2 -fPIC -ffat-lto-objects"
./configure "${configure_options[@]}"
make -j$(nproc)
sudo make install
# Cleanup and add to database
cd ..
sudo rm -rf ${filename} $direname
echo $version > /var/lib/lfs-custom-packages/$name
