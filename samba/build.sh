#!/bin/bash
set -e
name=samba
repo=$name-team/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.samba.org/pub/samba/stable/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
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
PYTHON=$PWD/pyvenv/bin/python3             \
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
