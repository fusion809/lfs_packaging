#!/bin/bash
set -e
name=zsh
repo=$name/code
version=$(sf_ver $repo)
direname="$name-$version"
filename="$direname.tar.xz"
depends=(glibc libcap ncurses pcre2 pcre2 perl texinfo)
sf_download $name $version $filename
unpk_enter "$filename" "$direname"
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
oldVer=$(pkgver $name)
if [[ "$oldVer" != "$version" ]]; then
	sudo rm -rf /usr/share/zsh/$oldVer /usr/lib/zsh/$oldVer /usr/bin/zsh-$oldVer
fi
echo "$version" | sudo tee /var/lib/custom-packages/$name
cd ..
sudo rm -rf $filename $direname
