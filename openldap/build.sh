#!/bin/bash
name=openldap
version=$(wget -cqO- https://www.openldap.org/software/download/OpenLDAP/openldap-release/ | grep "openldap-[0-9.]*.tgz\"" | cut -d '"' -f 2 | cut -d '-' -f 2 | sed 's/.tgz//g' | tail -n 1)
direname="$name-$version"
filename="$direname.tgz"
blfs_depends=(cyrus-sasl)

if ! [[ -f $filename ]]; then
	wget -c https://www.openldap.org/software/download/OpenLDAP/openldap-release/$filename
fi

rm -rf $direname
tar xf $filename
cd $direname
./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-static  \
            --enable-dynamic  \
            --disable-debug   \
            --disable-slapd   &&

make -j$(nproc) depend &&
make -j$(nproc)
sudo make install
cd ..
rm -rf $direname $filename
echo "$version" > /var/lib/custom-packages/$name
