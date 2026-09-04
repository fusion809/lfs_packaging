#!/bin/bash
set -e
name=nss
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://archive.mozilla.org/pub/security/nss/releases/ | grep -oE "NSS_[0-9]+_[0-9]+" | sed 's/NSS_//g' | sed 's/_/./g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/mozilla/nss.git | grep -oE 'NSS_[0-9_]+RTM' | sed 's/NSS_//g' | sed 's/_RTM//g' | tr '_' '.' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(glibc nspr sqlite zlib)
blfs_depends=(libtasn1)
majVer=$(echo $version | cut -d '.' -f 1)
minVer=$(echo $version | cut -d '.' -f 2)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://archive.mozilla.org/pub/security/nss/releases/NSS_${majVer}_${minVer}_RTM/src/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
gap_patches $name
cd nss &&

make -j$(nproc) BUILD_OPT=1                      \
  NSPR_INCLUDE_DIR=/usr/include/nspr  \
  USE_SYSTEM_ZLIB=1                   \
  ZLIB_LIBS=-lz                       \
  NSS_ENABLE_WERROR=0                 \
  NSS_USE_SYSTEM_SQLITE=1             \
  USE_64=1
cd ../dist
sudo su -c "install -v -m755 Linux*/lib/*.so  /usr/lib         &&
install -v -m644 Linux*/lib/*.chk /usr/lib         &&

install -v -m755 -d               /usr/include/nss &&
cp -v -RL {public,private}/nss/*  /usr/include/nss &&

install -v -m755 Linux*/bin/{certutil,nss-config,pk12util} /usr/bin &&

install -v -m644 Linux*/lib/pkgconfig/nss.pc  /usr/lib/pkgconfig"
sudo ln -sfv ./pkcs11/p11-kit-trust.so /usr/lib/libnssckbi.so
cd ../..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
