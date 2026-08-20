#!/bin/bash
# BLFS book compiles it with configure, make and make install
# That method of installation leads to:
# libssh.cps
# libsshConfig.cmake
# libssh-config.cmake
# files being omitted from install
# cmake-based installation is required
set -e
name=libssh2
version=$(gh_ver "$name/$name")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
lfs_depends=(cmake gcc glibc openssl zlib)

if ! [[ -f $filename ]]; then
	wget -c https://www.libssh2.org/download/$filename
fi
if ! [[ -f "libssh2-1.11.1-security_fixes-1.patch" ]]; then
	wget -c https://www.linuxfromscratch.org/patches/blfs/svn/libssh2-1.11.1-security_fixes-1.patch
fi
rm -rf $direname
tar xf $filename
cd $direname
patch -Np1 -i ../libssh2-1.11.1-security_fixes-1.patch
#cmi --prefix=/usr --disable-docker-tests
cmake_options=(
	-DCMAKE_INSTALL_PREFIX=/usr
	-DCMAKE_RUN_DOCKER_TESTS=false
	-DBUILD_STATIC_LIBS=OFF
)
cmaki "${cmake_options[@]}" 
cd ..
#rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
