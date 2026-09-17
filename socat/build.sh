#!/bin/bash
set -e
name=socat
get_version() {
	local inst_ver=$(pkgver $name)
    local up_ver=$(wget -T 5 -cqO- http://www.dest-unreach.org/socat/ | grep "download/socat-" | head -n 1 | cut -d '"' -f 2 | sed 's|download/socat-||g' | sed 's/.tar.gz//g')
    ver_check "$up_ver" "$inst_ver" && return

    local git_ver=$(git ls-remote --tags --refs https://repo.or.cz/socat.git | grep "refs/tags/tag-[0-9.]*$" | cut -d '-' -f 2 | sort -V | tail -n 1)
    ver_check "$git_ver" "$inst_ver" && return

    local vat_ver=$(vatver $name)
    ver_check "$vat_ver" "$inst_ver" && return

    local arch_ver=$(aver $name)
    ver_check "$arch_ver" "$inst_ver" && return

	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return

	fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$name-$version.tar.gz"
direname="$name-$version"
depends=(glibc ncurses openssl readline)

download_src "https://repo.or.cz/socat.git/snapshot/refs/tags/tag-$version.tar.gz" "$filename"
unpk_enter "$filename" "$direname"
sed -i -e "s|pName->d.iPAddress->data|ASN1_STRING_get0_data(pName->d.iPAddress)|g" \
	-e "s|pName->d.iPAddress->length|ASN1_STRING_length(pName->d.iPAddress)|g" xio-openssl.c
configure_options=(
    --prefix=/usr \
    --mandir=/usr/share/man
)
cmi "${configure_options[@]}"
cd ..
rm -rf "$direname" "$filename"
echo "$version" | sudo tee /var/lib/custom-packages/$name
