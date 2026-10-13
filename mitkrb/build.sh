#!/bin/bash
set -e
name=mitkrb
_name=krb5
homepage="http://web.mit.edu/kerberos/"
description="The Kerberos network authentication system."
dist="https://kerberos.org/dist/krb5/"
majMinVer=$(wget -T 5 -t 1 -cqO- $dist | grep "/</a>" | tail -n 1 | 
	cut -d '"' -f 8 | sed 's|/||g')
get_version() {
  local inst_ver=$(pkgver $name)
  local lfs_vers=$(lfs_ver $name)
  if echo "$majVer" | grep -q "[0-9]"; then
    local version=$(wget -T 5 -t 1 -cqO- $dist/$majMinVer/ | cut -d '"' -f 8 | 
	    grep "^krb5" | grep -v "asc" | cut -d '-' -f 2 | 
	    sed 's/.tar.gz//g' | sort | uniq | tail -n 1)
    ver_check "$version" "$inst_ver" "$lfs_vers" && return
  fi
  local mon_ver=$(uver $name | sed 's/-final//g')
  ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
  local vat_ver=$(vatver $_name)
  ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
  local arch_ver=$(aver $_name)
  ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
  local art_ver=$(artver $_name)
  ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
  local nix_ver=$(nixver $_name)
  ver_check "$nix_ver" "$inst_ver" "$lfs_vers" && return
  fver "$name" "$inst_ver"
}
version=$(get_version)
dirname="$_name-$version"
filename="$dirname.tar.gz"
depends=(bash e2fsprogs glibc keyutils lmdb openssl)
download_src "$dist/$majMinVer/$filename"
unpk_enter "$filename" "$direname"
gap_patches $name
cd src &&
sed -i -e '/eq 0/{N;s/12 //}' plugins/kdb/db2/libdb2/test/run.test &&

configure_options=(
    --prefix=/usr            \
    --sysconfdir=/etc        \
    --localstatedir=/var/lib \
    --runstatedir=/run       \
    --with-system-et         \
    --with-system-ss         \
    --with-system-verto=no   \
    --enable-dns-for-realm   \
    --disable-rpath
)
cmi "${configure_options[@]}"
sudo cp -vfr ../doc -T /usr/share/doc/$dirname
export CP="/var/lib/custom-packages"
echo "$version" | sudo tee "$CP/$name"
rm -rf $dirname $filename
