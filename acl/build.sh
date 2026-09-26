#!/bin/bash
set -e
name=acl
homepage="https://savannah.nongnu.org/projects/acl"
description="Access control list utilities, libraries and headers"
version=$(ngnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gcc glibc make tar wget xz)
download_src https://download.savannah.nongnu.org/releases/$name/$filename || download_git https://git.savannah.nongnu.org/git/$name.git
unpk_enter "$name" "$version"
cmi --prefix=/usr --disable-static --sysconfdir=/etc --docdir=/usr/share/doc/$direname
cd ..
rm -rf $filename $direname $name
echo "$version" | sudo tee /var/lib/custom-packages/$name
