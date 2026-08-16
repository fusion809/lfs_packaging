#!/bin/bash
set -e
name=xmlto
get_version() {
	local up_ver=$(wget -T 5 -cqO- https://pagure.io/xmlto/releases | grep "/xmlto/archive/.*tar.gz" | cut -d '"' -f 2 | cut -d '/' -f 4)
	if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$up_ver"
		return 0
	fi

	local git_ver=$(git ls-remote --tags --refs https://pagure.io/xmlto.git | grep "refs/tags/" | cut -d '/' -f 3)
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
direname="$name-$version"
filename="$direname.tar.gz"
blfs_depends=(docbook-xml docbook-xsl-nons libxslt)
xslver=$(cat /var/lib/book-packages/docbook-xsl-nons | head -n 1)

if ! [[ -f $filename ]]; then
	wget -c https://pagure.io/xmlto/archive/$version/$filename
fi

tar xf "$filename"
cd "$direname"
sed -i -e "s|http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl|/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2/manpages/docbook.xsl|g" format/docbook/man
autoreconf -fiv                                  &&
LINKS="/usr/bin/links" ./configure --prefix=/usr &&

make -j$(nproc)
sudo make install
cd ..
rm -rf "$direname"
echo "$version" > /var/lib/custom-packages/$name
