#!/bin/bash
set -e
# Variable declaration
name=udisks
version=$(gh_ver "storaged-project/udisks")
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
depends=(acl elogind glib2 glib2 glibc kmod libatasmart libblockdev libffi libgudev openssl pcre2 polkit polkit systemd util-linux xz zlib zstd)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/storaged-project/udisks/releases/download/$direname/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
./configure --prefix=/usr        \
            --sysconfdir=/etc    \
            --localstatedir=/var \
            --disable-static     \
            --enable-available-modules &&
docbook_ver=$(pkgver docbook-xsl-nons)
sed -i -e "s|http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl|/usr/share/xml/docbook/xsl-stylesheets-nons-$docbook_ver/manpages/docbook.xsl|g" doc/man/Makefile
maki
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
