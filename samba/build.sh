#!/bin/bash
set -e
name=samba
repo=$name-team/$name
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://download.samba.org/pub/samba/stable/ | grep "samba-[0-9]+\.[0-9]+\.[0-9]+" -oE | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	echo "$(gh_ver $repo)"
}
version=$(get_version)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://download.samba.org/pub/samba/stable/$filename"
unpk_enter "$filename" "$direname"
options=(--prefix=/usr                          \
    --sysconfdir=/etc                      \
    --localstatedir=/var                   \
    --with-piddir=/run/samba               \
    --with-pammodulesdir=/usr/lib/security \
    --enable-fhs                           \
    --without-ad-dc                        \
    --with-system-mitkrb5                  \
    --with-systemd                         \
    --enable-selftest                      \
    --disable-rpath-install                \
    --systemd-install-services)
#PYTHON=$PWD/pyvenv/bin/python3             \
export XSLTPROC=false # Required to prevent documentation build failure errors
./configure "${options[@]}"
make -j$(nproc)
sed '1s@^.*$@#!/usr/bin/python3@' \
    -i ./bin/default/source4/scripting/bin/*.inst
sudo su -c 'make install &&

install -v -m644 examples/smb.conf.default /etc/samba &&

sed -e "s;log file =.*;log file = /var/log/samba/%m.log;"   \
    -e "s;path = /usr/spool/samba;path = /var/spool/samba;" \
    -i /etc/samba/smb.conf.default &&

mkdir -pv /etc/openldap/schema &&

install -v -m644    examples/LDAP/README \
                    /etc/openldap/schema/README.samba &&

install -v -m644    examples/LDAP/samba* \
                    /etc/openldap/schema &&

install -v -m755    examples/LDAP/{get*,ol*} \
                    /etc/openldap/schema'
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
