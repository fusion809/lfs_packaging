#!/bin/bash
set -e
name=zsh
get_version() {
    local up_ver=$(git ls-remote --tags --refs git://git.code.sf.net/p/zsh/code.git | grep "refs/tags/zsh-[0-9.]*$" | cut -d '-' -f 2 | sort -V | tail -n 1)
    ver_check "$up_ver" && return
    local git_ver=$(git ls-remote --tags --refs git://git.code.sf.net/p/zsh/code.git | grep "refs/tags/zsh-[0-9.]*$" | cut -d '-' -f 2 | sort -V | tail -n 1)
    ver_check "$git_ver" && return

    local arch_ver=$(aver $name)
    ver_check "$arch_ver" && return
}
version=$(get_version)
direname="$name-$version"
filename="$direname.tar.xz"
depends=(pcre2)
lfs_depends=(glibc libcap ncurses pcre2 perl texinfo)
blfs_depends=()
if ! [[ -f $filename ]]; then
	wget -c https://sourceforge.net/projects/zsh/files/zsh/$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
./Util/preconfig
configure_options=(
    --prefix=/usr \
    --sysconfdir=/etc/zsh \
    --enable-etcdir=/etc/zsh \
    --enable-cap \
    --enable-pcre \
    --enable-dynamic \
    --enable-readnullcmd=pager \
    --with-tcsetpgrp
)
cmi "${configure_options[@]}"
sudo make infodir=/usr/share/info install.info
old_version=$(cat /var/lib/custom-packages/$name | head -n 1)
if [[ "$old_version" != "$version" ]]; then
	sudo rm -rf /usr/share/zsh/$old_version
fi
echo "$version" > /var/lib/custom-packages/$name
cd ..
rm -rf $filename $direname
