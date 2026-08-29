#!/bin/bash
set -e
name=bzip2
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -cqO- https://www.sourceware.org/pub/$name/ | grep "$name-[0-9.]*.tar.gz" | cut -d '"' -f 8 | sed 's/.tar.gz.*$//g' | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(git ls-remote --tags --refs https://sourceware.org/git/$name.git | grep -E "$name-[0-9.]+$" | cut -d '/' -f 3 | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
lfs_depends=(gcc make tar coreutils gzip)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.sourceware.org/pub/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
gap_patches
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so
make clean
make -j$(nproc)
sudo make PREFIX=/usr install
majVer=$(echo $version | cut -d '.' -f 1)
sudo su -c "cp -av libbz2.so.* /usr/lib
ln -sfv libbz2.so.$version /usr/lib/libbz2.so
ln -sfv libbz2.so.$version /usr/lib/libbz2.so.$majVer
cp -v bzip2-shared /usr/bin/bzip2
"
sudo su -c 'for i in /usr/bin/{bzcat,bunzip2}; do
  ln -sfv bzip2 $i
done
rm -fv /usr/lib/libbz2.a
'
cd ..
rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
