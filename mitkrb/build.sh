#!/bin/bash
set -e
name=mitkrb 
get_version() {
    local majVer=$(wget -T 5 -cqO- https://kerberos.org/dist/krb5/ | grep "/</a>" | tail -n 1 | cut -d '"' -f 8 | sed 's|/||g')
    if echo "$majVer" | grep -q "[0-9]"; then
        local version=$(wget -T 5 -cqO- https://kerberos.org/dist/krb5/$majVer/ | cut -d '"' -f 8 | grep "^krb5" | grep -v "asc" | cut -d '-' -f 2 | sed 's/.tar.gz//g' | sort | uniq | tail -n 1)
        if echo "$version" | grep -q "[0-9]\.[0-9]"; then
            echo "$version"
            return 0
        fi
    fi
    local arch_ver=$(aver $name)
    if echo "$arch_ver" | grep -q "[0-9]\.[0-9]"; then
        echo "$arch_ver"
        return 0
    fi
}
version=$(get_version)
dirname="krb5-$version"
filename="$dirname.tar.gz"
depends=()
lfs_depends=(bash e2fsprogs glibc openssl)
blfs_depends=()

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

./configure --prefix=/usr            \
            --sysconfdir=/etc        \
            --localstatedir=/var/lib \
            --runstatedir=/run       \
            --with-system-et         \
            --with-system-ss         \
            --with-system-verto=no   \
            --enable-dns-for-realm   \
            --disable-rpath          &&
	    make -j$(nproc)
sudo make install &&
export DDIR="/tmp/destdir_mitkrb"
rm -rf "$DDIR" && mkdir -p "$DDIR"
# Force prefix=/usr for install to ensure it skips /usr/local
make install DESTDIR="$DDIR" || true
if [ -d "$DDIR" ] && [ "$(ls -A "$DDIR" 2>/dev/null)" ]; then
    sudo mkdir -p "$CP"
    find "$DDIR" -type f -o -type l | sed "s|^$DDIR||" | sudo tee -a "$CP/$name" > /dev/null
fi
sudo rm -rf "$DDIR"
sudo cp -vfr ../doc -T /usr/share/doc/$dirname
export CP="/var/lib/custom-packages"
echo "$version" > "$CP/$name"
sudo chmod 777 "$CP/$name"
rm -rf $dirname $filename
