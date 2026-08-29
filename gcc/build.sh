#!/bin/bash
set -e
name=gcc
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
lfs_depends=(gcc glibc make ncurses tar wget xz)
if ! [[ -f $filename ]]; then
    wget -c https://ftpmirror.gnu.org/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
mkdir -v build
cd build
../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++,fortran \
             --enable-default-pie     \
             --enable-default-ssp     \
             --enable-host-pie        \
             --enable-targets=all     \
             --disable-multilib       \
             --disable-bootstrap      \
             --disable-fixincludes    \
             --with-system-zlib
make -j$(nproc)
ulimit -s -H unlimited
chown -R tester .
if ! (su tester -c "PATH=$PATH make -k check"); then
	../contrib/test_summary -t
	read -p 'Build failed tests. Proceed to installation anyway? [y/N] ' -n 1 -r < /dev/tty
	echo
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		exit 1
	fi
fi
sudo make install
sudo su -c "ln -svr /usr/bin/cpp /usr/lib
ln -sv gcc.1 /usr/share/man/man1/cc.1
ln -sfvr $(gcc -print-prog-name=liblto_plugin.so) /usr/lib/bfd-plugins/
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib"
cd ../..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
