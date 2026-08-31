#!/bin/bash
name=kbd
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 2 -t 1 -cqO- https://www.kernel.org/pub/linux/utils/kbd/ | grep -E "$name-[0-9]+\.[0-9]+\.[0-9]+" | cut -d '"' -f 2 | sed 's/.tar.*//g' | cut -d '-' -f 2 | sort -V | uniq | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 2 git ls-remote --tags --refs git://git.kernel.org/pub/scm/linux/kernel/git/legion/kbd.git | grep -E "refs/tags/v[0-9]+\.[0-9]+\.[0-9]+" | cut -d '/' -f 3 | sed 's/^v//g' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
lfs_depends=(glibc gcc make tar xz coreutils bash)
blfs_depends=(libxkbcommon)
depends=(glibc)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.kernel.org/pub/linux/utils/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
gap_patches $name
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
cmi --prefix=/usr --disable-vlock
sudo cp -R -v docs/doc -T /usr/share/doc/$direname
cd ..
echo $version > /var/lib/custom-packages/$name
