#!/bin/bash
set -e
# Variable declaration
name=udisks
repo="storaged-project/udisks"
version=$(gh_ver $repo)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
depends=(acl elogind glib2 glib2 glibc kmod libatasmart libblockdev libffi libgudev openssl pcre2 polkit polkit systemd util-linux xz zlib zstd)
# Fetch source and unpack it
ghr_download "$repo" "$direname" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
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
