#!/bin/bash
set -e
name=xmlto
homepage="https://pagure.io/xmlto/"
description="Convert xml to many other formats"
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -cqO- https://pagure.io/xmlto/releases | grep "/xmlto/archive/.*tar.gz" | cut -d '"' -f 2 | cut -d '/' -f 4)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return

	local git_ver=$(git ls-remote --tags --refs https://pagure.io/xmlto.git | grep "refs/tags/" | cut -d '/' -f 3)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return

	fver "$name" "$inst_ver"
}

version=$(get_version)
direname="$name-$version"
filename="$direname.tar.gz"
depends=(docbook-xml docbook-xsl-nons glibc libxslt)
xslver=$(cat /var/lib/custom-packages/docbook-xsl-nons | head -n 1)
download_src "https://pagure.io/xmlto/archive/$version/$filename" || download_src "https://releases.pagure.org/xmlto/$filename"
unpk_enter "$filename" "$direname"
docbook_ver=$(pkgver docbook-xsl-nons)
sed -i -e "s|http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl|/usr/share/xml/docbook/xsl-stylesheets-nons-$docbook_ver/manpages/docbook.xsl|g" format/docbook/man
sudo autoreconf -fiv                                  &&
sudo chown $USER -R .
LINKS="/usr/bin/links" cmi --prefix=/usr
cd ..
rm -rf "$direname"
echo "$version" | sudo tee /var/lib/custom-packages/$name
