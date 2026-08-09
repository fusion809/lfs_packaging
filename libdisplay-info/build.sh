#!/bin/bash
name=libdisplay-info
git_ver=$(git ls-remote --tags https://gitlab.freedesktop.org/emersion/libdisplay-info.git | grep -v "\^{}" | cut -d '/' -f 3 | tail -n 1)
arch_ver=$(wget -cqO- -T 10 "https://gitlab.archlinux.org/archlinux/packaging/packages/$name/-/raw/main/PKGBUILD" | grep "^pkgver=" | cut -d '=' -f 2)
version=${git_ver:-$arch_ver}
direname="$name-$version"
filename="$direname.tar.xz"
blfs_depends=(hwdata)

if ! [[ -f $filename ]]; then
	wget -c https://gitlab.freedesktop.org/emersion/libdisplay-info/-/releases/$version/downloads/$filename
fi
rm -rf "$direname"
tar xf $filename
cd $direname
mkdir build &&
cd    build &&

meson setup --prefix=/usr --buildtype=release .. &&
ninja -j$(nproc)
sudo ninja install
cd ../..
rm -rf $direname $filename
echo "$version" > /var/lib/custom-packages/$name
