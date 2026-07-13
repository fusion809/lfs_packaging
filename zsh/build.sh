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
./Util/preconfig
./configure --prefix=/usr \
            --sysconfdir=/etc/zsh \
            --enable-etcdir=/etc/zsh \
            --enable-cap \
            --enable-pcre \
            --enable-dynamic \
            --enable-readnullcmd=pager \
            --with-tcsetpgrp
make -j$(nproc)
sudo make install
DDIR="/tmp/destdir_zsh"
rm -rf "$DDIR" && mkdir -p "$DDIR"
make install DESTDIR="$DDIR" || true
make infodir=/usr/share/info install.info DESTDIR="$DDIR" || true
sudo make install
sudo make infodir=/usr/share/info install.info
sudo chmod 777 /var/lib/custom-packages/$name
old_version=$(cat /var/lib/custom-packages/$name | head -n 1)
sudo rm -rf /usr/share/zsh/$old_version
echo "$version" > /var/lib/custom-packages/$name
cd ..
rm -rf $filename $direname
