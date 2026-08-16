#!/bin/bash
set -e
name=zsh
get_version() {
    local up_ver=$(git ls-remote --tags --refs git://git.code.sf.net/p/zsh/code.git | grep "refs/tags/zsh-[0-9.]*$" | cut -d '-' -f 2 | sort -V | tail -n 1)
    if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
        echo "$up_ver"
        return 0
    fi
    local git_ver=$(git ls-remote --tags --refs git://git.code.sf.net/p/zsh/code.git | grep "refs/tags/zsh-[0-9.]*$" | cut -d '-' -f 2 | sort -V | tail -n 1)
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
if [[ "$old_version" != "$version" ]]; then
	sudo rm -rf /usr/share/zsh/$old_version
fi
echo "$version" > /var/lib/custom-packages/$name
cd ..
rm -rf $filename $direname
