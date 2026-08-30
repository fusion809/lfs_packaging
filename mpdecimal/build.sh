#!/bin/bash
set -e
name=mpdecimal
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://www.bytereef.org/mpdecimal/download.html | grep "\.tar\.gz" | head -n 1 | cut -d '/' -f 5 | cut -d '"' -f 1 | sed 's/mpdecimal-//g' | sed 's/.tar.*z//g')
	ver_check "$up_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.bytereef.org/software/mpdecimal/releases/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
configure_options=(--prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/$direname)
cmi "${configure_options[@]}"
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
