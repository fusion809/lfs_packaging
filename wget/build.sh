#!/bin/bash
set -e
name=wget
version=$(gnu_ver $name)
depends=(glibc libidn2 libpsl libunistring openssl pcre2 util-linux zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://ftpmirror.gnu.org/$name/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
NEW_LINE='#if !defined OPENSSL_NO_SSL3_METHOD '
NEW_LINE+='&& OPENSSL_VERSION_NUMBER < 0x40000000L'

sed -i "/SSL3/c $NEW_LINE" src/openssl.c

unset NEW_LINE
cmi --prefix=/usr --sysconfdir=/etc --with-ssl=openssl
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
