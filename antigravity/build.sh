#!/bin/bash
set -e
name=antigravity
depends=()
lfs_depends=(bash coreutils glibc sed tar)
blfs_depends=(libarchive 
libx11 libxkbfile # Xorg libraries
wget)
eval "$(curl -s "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=antigravity-ide" \
  | grep -E '^(pkgver|_build)=' | sed 's|pkgver|version|g' \
  | head -2)"

echo "filename=$filename"
echo "direname=$direname"
if ! [[ -f $filename ]]; then
	wget -c "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/$version-$_build/linux-x64/$filename"
fi
tar xf "$filename"
sudo mkdir -p /usr/share/antigravity
sudo cp -r "$direname"/* /usr/share/antigravity
sudo cp -r "$direname"/bin/* /usr/bin/
sudo cp $name.desktop /usr/share/applications/
sudo cp $name.png /usr/share/pixmaps/
cd ..
sudo rm -rf "$direname" "$filename"
echo $version > /var/lib/custom-packages/$name
