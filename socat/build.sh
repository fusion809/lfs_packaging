#!/bin/bash
set -e
name=socat
get_version() {
    local up_ver=$(wget -T 5 -cqO- http://www.dest-unreach.org/socat/ | grep "download/socat-" | head -n 1 | cut -d '"' -f 2 | sed 's|download/socat-||g' | sed 's/.tar.gz//g')
    if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
        echo "$up_ver"
        return 0
    fi

    local git_ver=$(git ls-remote --tags --refs https://repo.or.cz/socat.git | grep "refs/tags/tag-[0-9.]*$" | cut -d '-' -f 2 | sort -V | tail -n 1)
    if echo "$git_ver" | grep -q "[0-9]\.[0-9]"; then
        echo "$git_ver"
        return 0
    fi

    local arch_ver=$(aver $name)
    if echo "$arch_ver" | grep -q "[0-9]\.[0-9]"; then
        echo "$arch_ver"
        return 0
    fi
}
version=$(get_version)
filename="$name-$version.tar.gz"
direname="$name-$version"
lfs_depends=(glibc openssl readline)

rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c http://www.dest-unreach.org/socat/download/$filename
fi

tar xf "$filename"
cd "$direname"
./configure \
    --prefix=/usr \
    --mandir=/usr/share/man
sed -i -e "s|pName->d.iPAddress->data|ASN1_STRING_get0_data(pName->d.iPAddress)|g" \
	-e "s|pName->d.iPAddress->length|ASN1_STRING_length(pName->d.iPAddress)|g" xio-openssl.c
make -j$(nproc)
sudo make install
cd ..
rm -rf "$direname" "$filename"
echo "$version" > /var/lib/custom-packages/$name
