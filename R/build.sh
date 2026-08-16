#!/bin/bash
set -e
# Variable declarations
name=R
function R_version {
  local up_ver1=$(wget -cqO- https://cran.r-project.org/sources.html | grep ".tar.gz" | grep -v "alpha\|beta\|\.rc" | head -n 1 | cut -d '"' -f 2 | cut -d '/' -f 4 | sed 's/.tar.gz//g' | cut -d '-' -f 2) 
  ver_check "$up_ver1" && return

  local up_ver2=$(
    curl -fsSL https://cran.r-project.org/src/base/ |
    grep -oE 'href="R-[0-9]+/"' |
    grep -oE '[0-9]+' |
    sort -V |
    tail -n1 |
    xargs -I{} curl -fsSL "https://cran.r-project.org/src/base/R-{}/" |
    grep -oE 'R-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz' |
    sort -V |
    tail -n1 |
    sed 's/^R-//; s/\.tar\.gz$//'
  )
  ver_check "$up_ver2" && return

  local arch_ver=$(aver $name)
  ver_check "$arch_ver" && return
}
version=$(R_version)
direname="$name-$version"
filename="$direname.tar.xz"
depends=(blas lapack pcre2)
lfs_depends=(bash bzip2 coreutils glibc make readline sed tar xz zlib zstd)
blfs_depends=(cairo curl gcc glib icu java libjpeg-turbo libpng libtiff libtirpc libx11 libxmu libxt pango tk which zip)
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://cran.r-project.org/src/base/$name-${version/.*/}/$filename
fi
tar xvf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./configure \
  --prefix=/usr \
  --libdir=/usr/lib \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --mandir=/usr/man \
  rdocdir=/usr/share/doc/$direname \
  --enable-R-shlib \
  --with-blas="-lblas" \
  --with-lapack="-llapack"

make -j$(nproc)
sudo make install DESTDIR=/

sudo mkdir -p /usr/share/doc/$direname
sudo cp -a \
   COPYING README SVN-REVISION VERSION VERSION-NICK \
   /usr/share/doc/$direname
cd ..
sudo install -Dm755 $name.desktop /usr/share/applications
# Cleanup and add to database
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
