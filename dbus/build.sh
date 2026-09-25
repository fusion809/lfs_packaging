#!/bin/bash
set -e
name=dbus
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://dbus.freedesktop.org/releases/dbus/ | grep -oE "dbus-[0-9]+\.[0-9]+\.[0-9]+" | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://gitlab.freedesktop.org/dbus/dbus.git | grep "refs/tags/dbus-[0-9]+\.[0-9]+\.[0-9]+" -oE | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"	
}
version=$(get_version)
depends=(expat glibc libx11 libxau libxcb libxdmcp systemd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://dbus.freedesktop.org/releases/dbus/$filename"
unpk_enter "$filename" "$direname"
meson_options=(
	--prefix=/usr \
	--buildtype=release \
	--wrap-mode=nofallback
)
mni "${meson_options[@]}"
if [ -e /usr/share/doc/dbus ]; then
  sudo rm -rf /usr/share/doc/$direname    &&
  sudo mv -v  /usr/share/doc/dbus{,-$version}
fi
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
