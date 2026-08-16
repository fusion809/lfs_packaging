#!/bin/bash
name=libdisplay-info
get_version() {
	local up_ver=$(wget --timeout=5 -cqO- https://gitlab.freedesktop.org/emersion/libdisplay-info/-/tags | grep "tags/" | grep -v "dev\|rc" | cut -d '/' -f 6 | sed 's/".*//g' | sort -V | tail -n 1)
	ver_check "$up_ver" && return

	local git_ver=$(git ls-remote --tags https://gitlab.freedesktop.org/emersion/libdisplay-info.git | grep -v "\^{}" | cut -d '/' -f 3 | tail -n 1)
	ver_check "$git_ver" && return

	local blfs_ver=$(wget --timeout=5 -cqO- https://www.linuxfromscratch.org/blfs/view/systemd/index.html | grep "$name" | sed "s/.*$name-//g" | sed 's|</a>||g')
	ver_check "$blfs_ver" && return
}

version=$(get_version)
git_ver=$(git ls-remote --tags https://gitlab.freedesktop.org/emersion/libdisplay-info.git | grep -v "\^{}" | cut -d '/' -f 3 | tail -n 1)

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
