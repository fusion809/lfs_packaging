#!/bin/bash
set -e
name=dbus
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://dbus.freedesktop.org/releases/dbus/ | grep -oE "dbus-[0-9]+\.[0-9]+\.[0-9]+" | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://gitlab.freedesktop.org/dbus/dbus.git | grep "refs/tags/dbus-[0-9]+\.[0-9]+\.[0-9]+" -oE | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"	
}
version=$(get_version)
depends=(expat glibc libX11 systemd)
blfs_depends=(libXau libXdmcp libxcb)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://dbus.freedesktop.org/releases/dbus/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
meson_options=(--prefix=/usr --buildtype=release --wrap-mode=nofallback)
mni "${meson_options[@]}"
if [ -e /usr/share/doc/dbus ]; then
  sudo rm -rf /usr/share/doc/$direname    &&
  sudo mv -v  /usr/share/doc/dbus{,-$version}
fi
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
