#!/bin/bash
set -e
name=perl-file-sharedir
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -cqO- -T 5 -t 1 https://www.cpan.org/authors/id/R/RE/REHSACK | grep "File-ShareDir-[0-9]+\.[0-9]+" -oE | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
filename="File-ShareDir-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(perl-file-sharedir-install)
if ! [[ -f $filename ]]; then
	wget -c https://www.cpan.org/authors/id/R/RE/REHSACK/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
perl Makefile.PL &&
maki
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
