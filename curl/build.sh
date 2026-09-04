#!/bin/bash
set -e
name=curl
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://curl.se/download | grep "curl-[0-9.]+.tar.xz" -oE | sed 's/.tar.xz//g' | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	echo $(gh_ver curl/curl)
}
version=$(get_version)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
blfs_depends=(brotli cyrus-sasl libpsl libunistring make-ca nghttp2)
depends=(glibc libidn2 libpsl libunistring nghttp2 openldap openssl zlib zstd)
if ! [[ -f $filename ]]; then
	wget -c https://curl.se/download/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --disable-static --with-openssl --with-ca-path=/etc/ssl/certs
sudo su -c "rm -rf docs/examples/.deps &&

find docs \( -name Makefile\* -o  \
             -name \*.1       -o  \
             -name \*.3       -o  \
             -name CMakeLists.txt \) -delete &&

cp -v -R docs -T /usr/share/doc/$direname"
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
