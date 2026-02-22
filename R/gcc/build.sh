#!/bin/bash
set -e
exec > >(tee -a ~/R_lfs/gcc/gcc-15.2.0-fortran.log ) 2>&1
NAME=gcc
VERSION=15.2.0
if ! [[ -f "/sources/archives/$NAME-$VERSION.tar.xz" ]]; then
	wget -c https://ftpmirror.gnu.org/gcc/$NAME-$VERSION/$NAME-$VERSION.tar.xz -O /sources/archives/$NAME-$VERSION.tar.xz
fi
tar xf /sources/archives/$NAME-$VERSION.tar.xz
cd $NAME-$VERSION
sed -i 's/char [*]q/const &/' libgomp/affinity-fmt.c

case $(uname -m) in
x86_64)
sed -i.orig '/m64=/s/lib64/lib/' gcc/config/i386/t-linux64
;;
esac
rm -rf build
mkdir -p build               &&
cd    build               &&
../configure              \
--prefix=/usr         \
--disable-multilib    \
--with-system-zlib    \
--enable-default-pie  \
--enable-default-ssp  \
--enable-host-pie     \
--disable-fixincludes \
--enable-languages=c,c++,fortran &&
make -j$(nproc)
GCCDIR=$HOME/R_lfs/gcc
INSTDIR=$GCCDIR/install
mkdir -p $INSTDIR
cd build
make install DESTDIR=$INSTDIR
mkdir -pv $INSTDIR/usr/share/gdb/auto-load/usr/lib
cp -v usr/lib/*gdb.py $INSTDIR/usr/share/gdb/auto-load/usr/lib
find . -type f | sort > $GCCDIR/gcc-install-files.txt
while read f; do
    if [ ! -e "/$f" ]; then
        echo "$f"
    fi
done < $GCCDIR/gcc-install-files.txt
sudo make install &&
sudo mkdir -pv /usr/share/gdb/auto-load/usr/lib              &&
sudo mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib &&
sudo chown -v -R root:root \
/usr/lib/gcc/*linux-gnu/15.2.0/include{,-fixed}     &&
sudo ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/15.2.0/liblto_plugin.so \
/usr/lib/bfd-plugins/
cd ../..
rm -rf $NAME-$VERSION
