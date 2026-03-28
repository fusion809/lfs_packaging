#!/bin/bash
name=vim
version=$(curl -sL https://github.com/vim/vim/tags | perl -nle 'while (m{href="/vim/vim/releases/tag/v\K[0-9.]+}g) { print $& }' | head -n 1)
vimdir=$(echo "vim$version" | sed -E 's/\.[0-9]+$//g' | sed 's/\.//g')
direname="$name-$version"
filename="$direname.tar.gz"
lfs_depends=()
blfs_depends=()
depends=()
if ! [[ -f "$filename" ]]; then
	wget -c https://github.com/vim/vim/archive/v$version.tar.gz -O $filename
fi
tar xf $filename
cd $direname
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
./configure --prefix=/usr
make -j$(nproc)
export DDIR="/tmp/destdir_vim"
rm -rf "$DDIR" && mkdir -p "$DDIR"
make install DESTDIR="$DDIR" || true
sudo make install
export CP="/var/lib/custom-packages"
if [ -d "$DDIR" ] && [ "$(ls -A "$DDIR" 2>/dev/null)" ]; then
    sudo mkdir -p $CP
    find "$DDIR" -type f -o -type l | sed "s|^$DDIR||" | sudo tee -a "$CP/$name" > /dev/null
fi
sudo rm -rf "$DDIR"
sudo chmod 777 /var/lib/custom-packages/$name
sudo rm -rf /usr/share/doc/vim-*
sudo ln -sv ../vim/$vimdir/doc /usr/share/doc/$direname || true
cd ..
rm -rf $filename $direname
