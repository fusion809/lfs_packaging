#!/bin/bash
set -e
name=libevdev
get_version() {
	local inst_ver=$(pkgver $name)
	local git_ver=$(timeout 5 git ls-remote --tags --refs git://git.freedesktop.org/git/libevdev.git | grep "refs/tags/libevdev-[0-9.]+" -oE | sed 's/.*libevdev-//g' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
# INPUT_EVDEV and INPUT_UINPUT kernel options required
if ! [[ -f $filename ]]; then
	wget -c https://www.freedesktop.org/software/libevdev/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
meson_options=(--prefix=$XORG_PREFIX     \
      --buildtype=release       \
      -D documentation=disabled \
      -D tests=disabled)
mni "${meson_options[@]}"
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
