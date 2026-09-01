#!/bin/bash
set -e
name=mitkrb 
get_version() {
  local inst_ver=$(pkgver $name)
  local majVer=$(wget -T 5 -cqO- https://kerberos.org/dist/krb5/ | grep "/</a>" | tail -n 1 | cut -d '"' -f 8 | sed 's|/||g')
  if echo "$majVer" | grep -q "[0-9]"; then
    local version=$(wget -T 5 -cqO- https://kerberos.org/dist/krb5/$majVer/ | cut -d '"' -f 8 | grep "^krb5" | grep -v "asc" | cut -d '-' -f 2 | sed 's/.tar.gz//g' | sort | uniq | tail -n 1)
    ver_check "$version" "$inst_ver" && return
  fi
  local arch_ver=$(aver $name)
  ver_check "$arch_ver" "$inst_ver" && return
  fver "$name" "$inst_ver"
}
version=$(get_version)
dirname="krb5-$version"
filename="$dirname.tar.gz"
depends=()
lfs_depends=(bash e2fsprogs glibc openssl)
blfs_depends=(keyutils lmdb)

if ! [ -f "$filename" ]; then
    wget -c "https://kerberos.org/dist/krb5/$majVer/$filename"
    wget -c https://www.linuxfromscratch.org/patches/blfs/svn/mitkrb-1.22.2-upstream_fix-1.patch https://www.linuxfromscratch.org/patches/blfs/svn/mitkrb-1.22.2-security_fix-1.patch https://www.linuxfromscratch.org/patches/blfs/svn/mitkrb-1.22.2-openssl_4_fixes-1.patch
fi
rm -rf "$dirname"
tar xf "$filename"
cd "$dirname"
patch -Np1 -i ../mitkrb-1.22.2-upstream_fix-1.patch
patch -Np1 -i ../mitkrb-1.22.2-security_fix-1.patch
patch -Np1 -i ../mitkrb-1.22.2-openssl_4_fixes-1.patch
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
echo "$version" > "$CP/$name"
sudo chmod 777 "$CP/$name"
rm -rf $dirname $filename
