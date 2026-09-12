#!/bin/bash
set -e
name=links
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -cqO- -T 5 -t 1 http://links.twibright.com/download/ | grep "links-[0-9]+\.[0-9]+" -oE | sed 's/links-//g' | sort -V | tail -n 1)
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
depends=(brotli bzip2 glibc gpm libevent ncurses openssl xz zlib zstd)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c http://links.twibright.com/download/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed '/*strchr/s/cast_const_char //g' -i ftp.c
cmi --prefix=/usr --mandir=/usr/share/man
sudo su -c "install -v -d -m755 /usr/share/doc/$direname &&
install -v -m644 doc/links_cal/* KEYS BRAILLE_HOWTO \
    /usr/share/doc/$direname"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
