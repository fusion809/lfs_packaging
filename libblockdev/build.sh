#!/bin/bash
set -e
name=libblockdev
homepage="https://github.com/storaged-project/libblockdev"
description="Library for manipulating block devices."
repo="storaged-project/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cryptsetup e2fsprogs gcc glib2 glibc gmp json-c keyutils kmod libatasmart libbytesize libffi libnvme libselinux lvm2 mpfr openssl pcre2 systemd util-linux xz zlib zstd)
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
configure_options=(--prefix=/usr      \
            --sysconfdir=/etc  \
            --with-python3     \
            --without-escrow   \
            --without-gtk-doc  \
            --without-lvm      \
            --without-lvm_dbus \
            --without-nvdimm   \
            --without-tools    \
	    --without-smartmontools)
cmi "${configure_options[@]}"
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
