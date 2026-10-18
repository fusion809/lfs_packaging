#!/bin/bash
set -e
name=tcsh
_name=TCSH
repo=$name-org/$name
homepage="https://www.tcsh.org/"
description="Enchanged version of the Berkeley C shell."
version=$(gh_ver $repo)
_version=$(echo $version | tr '.' '_')
tag="${_name}$_version"
filename="$name-$tag.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$tag" "$filename"
unpk_enter "$filename" "$direname"
config_options=(--prefix=/usr \
    --sysconfdir=/etc \
    --bindir=/usr/bin)
./configure "${config_options[@]}"
make -j$(nproc)
sudo su -c "make install install.man &&

ln -v -sf tcsh   /bin/csh &&
ln -v -sf tcsh.1 /usr/share/man/man1/csh.1"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
