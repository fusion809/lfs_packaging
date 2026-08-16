#!/bin/bash
set -e
# Variable declarations
name=lzip
# Get versions into temp variables (updates will include these because they are ABOVE the version= line)
get_version() {
	local up_ver=$(wget -cqO- -T 5 "https://download.savannah.gnu.org/releases/lzip/" | grep -oE 'lzip-[0-9.]+\.tar\.gz' | sort -V | tail -n 1 | sed -e 's/lzip-//' -e 's/.tar.gz//')
	ver_check "$up_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" && return
}

version=$(get_version)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=()
lfs_depends=(bash coreutils glibc gcc gzip make sed tar)
blfs_depends=(wget)
src="https://download.savannah.gnu.org/releases/$name/$filename"
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c $src
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
cmi --prefix=/usr
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
