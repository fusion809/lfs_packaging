#!/bin/bash
set -e
name=ncurses
get_version() {
    local inst_ver=$(pkgver $name)
    local up_ver=$(wget -T 5 -t 1 -cqO- https://invisible-mirror.net/archives/ncurses | grep -E "ncurses-[0-9.]+" | cut -d '"' -f 4 | grep -v "asc" | sed 's/.tar.*//g' | sed 's/ncurses-//g' | sort -V | tail -n 1)
    ver_check "$up_ver" "$inst_ver" && return
    local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/ThomasDickey/ncurses-snapshots.git | grep -E "refs/tags/v[0-9_]+" | cut -d '/' -f 3 | sed 's/v//g' | sed -E 's/_[0-9]+$//g' | tr '_' '.' | sort -V | tail -n 1)
    ver_check "$git_ver" "$inst_ver" && return
    local arch_ver=$(aver $name)
    ver_check "$arch_ver" "$inst_ver" && return
    local lfs_vers=$(lfs_ver $name)
    ver_check "$lfs_vers" "$inst_ver" && return
    fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
lfs_depends=(glibc gcc gzip tar sed make wget)
if ! [[ -f $filename ]]; then
    wget -c https://invisible-mirror.net/archives/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --with-pkg-config-libdir=/usr/lib/pkgconfig
make -j$(nproc)
make DESTDIR=$PWD/dest install
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i dest/usr/include/curses.h
sudo cp --remove-destination -av dest/* /
for lib in ncurses form panel menu ; do
    sudo ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
    sudo ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
done
sudo ln -sfv libncursesw.so /usr/lib/libcurses.so
sudo cp -v -R doc -T /usr/share/doc/$direname