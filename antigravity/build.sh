#!/bin/bash
set -e
name=antigravity
depends=()
lfs_depends=(bash coreutils glibc sed tar)
blfs_depends=(libarchive 
libx11 libxkbfile # Xorg libraries
wget)
version=$(wget -cqO- "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=antigravity-ide" | grep "^pkgver=" | sed 's/^pkgver=//g')
_build=$(wget -cqO- "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=antigravity-ide" | grep "^_build=" | sed 's/^_build=//g')

filename="Antigravity IDE.tar.gz"
direname="${filename/.tar.gz/}"
if ! [[ -f $filename ]]; then
	wget -c "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/$version-$_build/linux-x64/$filename"
fi
rm -rf "$direname"
tar xf "$filename"
sudo mkdir -p /usr/share/antigravity
sudo ln -sf /usr/share/antigravity/bin/antigravity-ide /usr/bin/
sudo cp -r "$direname"/* /usr/share/antigravity
sudo cp $name.desktop /usr/share/applications/
sudo cp $name.png /usr/share/pixmaps/
sudo rm -rf "$direname" "$filename"
echo $version > /var/lib/custom-packages/$name
