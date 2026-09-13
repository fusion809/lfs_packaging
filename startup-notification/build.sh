#!/bin/bash
set -e
name=startup-notification
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://www.freedesktop.org/software/startup-notification/releases/ | grep "startup-notification-[0-9]+\.[0-9]+" -oE | sed 's/startup-notification-//g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(glibc libX11)
blfs_depends=(libXau libXdmcp libxcb xcb-util)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://www.freedesktop.org/software/startup-notification/releases/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --disable-static
sudo install -v -m644 -D doc/startup-notification.txt \
    /usr/share/doc/$direname/startup-notification.txt
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
