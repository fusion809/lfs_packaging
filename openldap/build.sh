#!/bin/bash
name=openldap
get_version() {
    local up_ver=$(wget --timeout=5 -cqO- https://www.openldap.org/software/download/OpenLDAP/openldap-release/ | grep "openldap-[0-9.]*.tgz\"" | cut -d '"' -f 2 | cut -d '-' -f 2 | sed 's/.tgz//g' | tail -n 1)
    ver_check "$up_ver" && return

    local git_ver=$(git ls-remote --tags --refs "https://git.openldap.org/openldap/openldap.git" | grep -E "refs/tags/OPENLDAP_REL_ENG_[0-9_]+$" | sed 's/.*OPENLDAP_REL_ENG_//g' | tr '_' '.' | sort -V | tail -n 1)
    ver_check "$git_ver" && return

    local arch_ver=$(aver $name)
    ver_check "$arch_ver" && return
}
version=$(get_version)
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
