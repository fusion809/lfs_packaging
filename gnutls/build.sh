#!/bin/bash
set -e
name=gnutls
homepage="https://www.gnutls.org/"
description="Library which provides a secure layer over a reliable transport layer."
repo="$name/$name"
version=$(gh_ver $repo)
depends=(gcc glibc gmp libffi libidn2 libtasn1 libunistring make-ca nettle p11-kit libev)
repo_url="https://github.com/$repo.git"
if [[ ! -d "$name/.git" ]]; then
	rm -rf "$name"
	git clone --depth 1 --branch "$version" --recurse-submodules --shallow-submodules \
		"$repo_url" "$name"
fi

git -C "$name" remote set-url origin "$repo_url"
git -C "$name" fetch --prune --tags --depth=1 origin
git -C "$name" checkout --force --detach "$version"
git -C "$name" submodule sync --recursive
git -C "$name" submodule update --init --recursive --depth=1

cd "$name"
cmi --prefix=/usr --docdir=/usr/share/doc/$name --with-default-trust-store-pkcs11="pkcs11:"
echo $version | sudo tee /var/lib/custom-packages/$name
