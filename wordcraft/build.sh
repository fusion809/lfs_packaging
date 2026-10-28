#!/bin/bash
set -e
name=wordcraft
repo=storytold/$name
description="Vibe coded clean-room reimplementation of Microsoft Word."
homepage="https://getartcraft.com/apps/wordcraft"
version=$(gh_ver $repo)
depends=(acl avahi bzip2 cups cyrus-sasl dbus e2fsprogs gcc glibc gmp gnutls icu jansson keyutils libarchive libcap libffi libidn2 libtasn1 libtirpc libunistring libxcrypt libxml2 linux-pam lmdb lz4 mitkrb ncurses nettle openldap openssl p11-kit popt python readline systemd xz zlib zstd)
conflicts=(wordcraft-bin)
craft_buildin $name $version
