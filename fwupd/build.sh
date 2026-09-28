#!/bin/bash
set -e
name=fwupd
repo=$name/$name
version=$(gh_ver $repo)
depends=(brotli curl cyrus-sasl e2fsprogs glib2 glibc gmp gnutls keyutils libdrm libffi libidn2 libmbim libpsl libqmi libsoup libtasn1 libunistring libusb libxmlb mitkrb ncurses nettle networkmanager nghttp2 openldap openssl p11-kit pcre2 polkit readline sqlite systemd util-linux xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
