#!/bin/bash
set -e
name=libaom
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://aomedia.googlesource.com/aom/ | grep "v[0-9]+\.[0-9]+\.[0-9]+" -oE | sed 's/.*v//g' | head -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://aomedia.googlesource.com/aom.git | grep -oE "refs/tags/v[0-9.]+" | sed 's/.*v//g' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
blfs_depends=(yasm)
depends=(gcc glibc)
if ! [[ -f $filename ]]; then
	wget -c https://storage.googleapis.com/aom-releases/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
sed -i 's/aom aom_static/aom/' cmake/aom_install.cmake
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D BUILD_SHARED_LIBS=1       \
      -D ENABLE_DOCS=no            \
      -G Ninja)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
