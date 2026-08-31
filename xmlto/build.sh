#!/bin/bash
set -e
name=xmlto
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 2 -cqO- https://pagure.io/xmlto/releases | grep "/xmlto/archive/.*tar.gz" | cut -d '"' -f 2 | cut -d '/' -f 4)
	ver_check "$up_ver" "$inst_ver" && return

	local git_ver=$(git ls-remote --tags --refs https://pagure.io/xmlto.git | grep "refs/tags/" | cut -d '/' -f 3)
	ver_check "$git_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return

	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return

	fver "$name" "$inst_ver"
}

version=$(get_version)
direname="$name-$version"
filename="$direname.tar.gz"
blfs_depends=(docbook-xml docbook-xsl-nons libxslt)
lfs_depends=(glibc)
xslver=$(cat /var/lib/book-packages/docbook-xsl-nons | head -n 1)

if ! [[ -f $filename ]]; then
	wget -c https://pagure.io/xmlto/archive/$version/$filename
fi

tar xf "$filename"
cd "$direname"
sed -i -e "s|http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl|/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2/manpages/docbook.xsl|g" format/docbook/man
autoreconf -fiv                                  &&
LINKS="/usr/bin/links" cmi "--prefix=/usr"
cd ..
rm -rf "$direname"
echo "$version" > /var/lib/custom-packages/$name
