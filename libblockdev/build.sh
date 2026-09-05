#!/bin/bash
set -e
name=libblockdev
repo="storaged-project/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
blfs_depends=(glib2 cryptsetup keyutils libatasmart libbytesize libnvme lvm2)
depends=(e2fsprogs glib2 glibc gmp json-c keyutils kmod libatasmart libffi mpfr openssl pcre2 systemd util-linux xz zlib zstd)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/storaged-project/libblockdev/releases/download/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
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
