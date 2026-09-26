#!/bin/bash
set -e
# Variable declarations
name=gl2ps
homepage="https://geuz.org/gl2ps/"
description="an OpenGL to PostScript printing library"
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://geuz.org/gl2ps/src/ | grep "[0-9].tgz" | grep -v "alpha\|beta\|\.rc" | cut -d '"' -f 8 | tail -n 1 | sed 's/gl2ps-//g' | sed 's/.tgz//g')
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return

	local git_ver=$(timeout 5 git ls-remote --tags --refs https://gitlab.onelab.info/gl2ps/gl2ps.git | grep "gl2ps_" | tail -n 1 | cut -d '/' -f 3 | sed 's/gl2ps_//g' | tr '_' '.')
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}

version=$(get_version)
filename="$name-$version.tgz"
direname=${filename/.tgz/}
depends=(bash bzip2 cmake coreutils expat freeglut gcc glibc glu gzip libdrm libelf libffi libice libpciaccess libpng libSM libx11 libxau libxcb libxdmcp libxext libxi libxml2 libxmu libxrandr libxrender libxshmfence libxt libxxf86vm llvm lm-sensors make mesa sed spirv-tools tar util-linux xz zlib zstd)
# Fetch and unpack source
download_src "https://geuz.org/gl2ps/src/$filename"
unpk_enter "$filename" "$direname"
# Compile and install
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
export FORCE_SOURCE_DATE=1 # make pdftex adhere to SOURCE_DATE_EPOCH
options=(
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_EXE_LINKER_FLAGS=-lm \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5
)
cmaki "${options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
