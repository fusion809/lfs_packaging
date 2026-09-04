#!/bin/bash
set -e
name=x265
get_version() {
	local inst_ver=$(pkgver $name)
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://bitbucket.org/multicoreware/x265_git.git | grep -oE "refs/tags/[0-9.]+" | cut -d '/' -f 3 | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
filename="${name}_$version.tar.gz"
direname="${filename/.tar.*/}"
blfs_depends=(cmake nasm)
if ! [[ -f $filename ]]; then
	wget -c https://bitbucket.org/multicoreware/x265_git/downloads/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
sed -i 's/FORMAT_ELF/UNIX64 \&\& FORMAT_ELF/' source/common/x86/cpu-a.asm
mkdir bld &&
cd    bld &&

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D GIT_ARCHETYPE=1           \
      -W no-author                 \
      ../source                    &&
make -j$(nproc)
sudo make install
sudo rm -vf /usr/lib/libx265.a
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
