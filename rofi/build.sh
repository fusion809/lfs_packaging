#!/bin/bash
set -e
name=rofi
homepage="https://davatorium.github.io/rofi"
description="Window switcher, application launcher and dmenu replacement."
version=$(gh_ver davatorium/rofi)
depends=(abseil-cpp acl avahi brotli bzip2 colord cyrus-sasl dbus e2fsprogs fuse gcc glib2 glibc gmp gnutls gpgme icu jansson keyutils lcms2 libarchive libassuan libcap libffi libgpg-error libidn2 libpsl libsoup libtasn1 libunistring libxml2 lz4 mitkrb nettle nghttp2 openldap openssl ostree p11-kit pcre2 pipewire popt samba sqlite systemd util-linux xz zlib zstd)

if ! [[ -d rofi ]]; then
	git clone https://github.com/davatorium/rofi.git
fi
if ! [[ -d libgwater ]]; then
	git clone https://github.com/sardemff7/libgwater
fi

if ! [[ -d libnkutils ]]; then
	git clone https://github.com/sardemff7/libnkutils
fi
cd rofi
git checkout $version
git submodule init
git config submodule.subprojects/libgwater.url ../libgwater
git config submodule.subprojects/libnkutils.url ../libnkutils
git -c protocol.file.allow=always submodule update

mni "--prefix=/usr"
cd ..
rm -rf build
cd ..
echo "$version" | sudo tee /var/lib/custom-packages/$name
