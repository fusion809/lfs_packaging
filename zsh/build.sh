#!/bin/bash
set -e
name=zsh
version=$(wget -cqO- https://sourceforge.net/p/zsh/code/ref/master/tags/ | grep "zsh-[0-9.]*" | grep -v test | cut -d '"' -f 2 | cut -d '/' -f 6 | cut -d '-' -f 2 | tail -n 1)
direname="$name-$version"
filename="$direname.tar.xz"
depends=()
lfs_depends=(libcap pcre2)
blfs_depends=()
if ! [[ -f $filename ]]; then
	wget -c https://sourceforge.net/projects/zsh/files/zsh/$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
sed -e 's/^main/int &/'      \
    -e 's/exit(/return(/'    \
    -i aczsh.m4 configure.ac &&

sed -e 's/test = /&(char**)/' \
    -i configure.ac           &&

autoconf
./configure --prefix=/usr            \
            --sysconfdir=/etc/zsh    \
            --enable-etcdir=/etc/zsh \
            --enable-cap             \
            --enable-gdbm            &&
make -j$(nproc)          &&
DDIR="/tmp/destdir_zsh"
rm -rf "$DDIR" && mkdir -p "$DDIR"
make install DESTDIR="$DDIR" || true
make infodir=/usr/share/info install.info DESTDIR="$DDIR" || true
sudo make install
sudo make infodir=/usr/share/info install.info
export CP="/var/lib/custom-packages"
echo "$version" > $CP/$name
if [ -d "$DDIR" ] && [ "$(ls -A "$DDIR" 2>/dev/null)" ]; then
    sudo mkdir -p $CP
    find "$DDIR" -type f -o -type l | sed "s|^$DDIR||" | sudo tee -a "$CP/$name" > /dev/null
fi
sudo rm -rf "$DDIR"
sudo chmod 777 /var/lib/custom-packages/$name
cd ..
rm -rf $filename $direname
