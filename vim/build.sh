#!/bin/bash
set -e
name=vim
version=$(curl -sL https://github.com/vim/vim/tags | perl -nle 'while (m{href="/vim/vim/releases/tag/v\K[0-9.]+}g) { print $& }' | head -n 1)
majver=$(echo $version | cut -d . -f 1)
minver=$(echo $version | cut -d . -f 2)
vimdir=$(echo "${name}${majver}${minver}")
direname="$name-$version"
filename="$direname.tar.gz"
lfs_depends=(acl gawk glibc gpm libgcrypt zlib)
# Optional lfs_depends of libcanberra for sound support, tcl for tcl support
blfs_depends=()
# Optional blfs_depends of gtk3, libxt, lua, perl, python, ruby for GUI/language support
depends=()

if ! [[ -f "$filename" ]]; then
    wget -c https://github.com/vim/vim/archive/v$version.tar.gz -O $filename
fi

# Fixed extraction and build prefix issues
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

./configure --prefix=/usr
make -j$(nproc) prefix=/usr

export DDIR="/tmp/destdir_vim"
rm -rf "$DDIR" && mkdir -p "$DDIR"
# Force prefix=/usr for install to ensure it skips /usr/local
make install DESTDIR="$DDIR" prefix=/usr || true
sudo make install prefix=/usr

export CP="/var/lib/custom-packages"
echo "$version" | sudo tee "$CP/$name" > /dev/null
if [ -d "$DDIR" ] && [ "$(ls -A "$DDIR" 2>/dev/null)" ]; then
    sudo mkdir -p "$CP"
    find "$DDIR" -type f -o -type l | sed "s|^$DDIR||" | sudo tee -a "$CP/$name" > /dev/null
fi
sudo rm -rf "$DDIR"
sudo chmod 777 "/var/lib/custom-packages/$name"
sudo rm -rf /usr/share/doc/vim-*
sudo ln -sv ../vim/"$vimdir"/doc /usr/share/doc/"$direname" || true
cd ..
rm -rf "$direname" "$filename"
