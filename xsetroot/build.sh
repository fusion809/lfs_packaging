#!/bin/bash
set -e
# Variable declarations
name=xsetroot
source ~/lfs_packaging/shared-funcs.sh
get_version() {
	local up_ver=$(wget -cqO- https://xorg.freedesktop.org/archive/individual/app/ | grep "$name-" | grep '\.tar\.xz"' | tail -n 1 | cut -d '-' -f 2 | cut -d '"' -f 1 | sed 's/.tar.xz//g')
	if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$up_ver"
		return 0
	fi

	local git_ver=$(git ls-remote --tags --refs https://gitlab.freedesktop.org/xorg/app/xsetroot.git | grep "refs/tags/xsetroot-" | cut -d '-' -f 2 | tail -n 1)
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
direname="${name}-$version"
filename="$direname.tar.xz"
lfs_depends=(bash coreutils glibc make sed systemd tar util-linux xz zlib)
blfs_depends=(libpng mesa xbitmaps xcb-util libxcb fontconfig xorg-libs)
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://xorg.freedesktop.org/archive/individual/app/$filename
fi
tar xvf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
XORG_CONFIG="--prefix=/usr"
./configure $XORG_CONFIG
make -j$(nproc)
sudo make install
sudo rm -rf $direname $filename
sudo rm -f /usr/bin/xkeystone
echo $version > /var/lib/custom-packages/$name
