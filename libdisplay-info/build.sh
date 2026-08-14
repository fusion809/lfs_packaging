#!/bin/bash
name=libdisplay-info
source ~/lfs_packaging/shared-funcs.sh
get_version() {
	local up_ver=$(wget -cqO- https://gitlab.freedesktop.org/emersion/libdisplay-info/-/tags | grep "tags/" | grep -v "dev\|rc" | cut -d '/' -f 6 | sed 's/".*//g' | sort -V | tail -n 1)
	if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$up_ver"
		return 0
	fi

	local git_ver=$(git ls-remote --tags https://gitlab.freedesktop.org/emersion/libdisplay-info.git | grep -v "\^{}" | cut -d '/' -f 3 | tail -n 1)
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
