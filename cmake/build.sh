#!/bin/bash
set -e
name=cmake
get_version() {
	local inst_ver=$(pkgver $name)
	local majVer=$(wget -T 5 -t 1 -cqO- https://cmake.org/files/ | grep "v[0-9.]+" -oE | sed 's/^v//g' | sort -V | tail -n 1)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://cmake.org/files/v$majVer | grep "cmake-[0-9.]+.tar.gz" -oE | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://gitlab.kitware.com/cmake/cmake.git | grep "refs/tags/v[0-9.]+" -oE | sed 's|refs/tags/v||g' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
majVer=$(echo $version | sed 's/\.[0-9]+$//g')
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
blfs_depends=(curl libarchive libuv nghttp2)
if ! [[ -f $filename ]]; then
	wget -c https://cmake.org/files/v$majVer/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake &&

./bootstrap --prefix=/usr        \
            --system-libs        \
            --mandir=/share/man  \
            --no-system-jsoncpp  \
            --no-system-cppdap   \
            --no-system-librhash \
            --docdir=/share/doc/$direname &&
make -j$(nproc)
sudo make install
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
