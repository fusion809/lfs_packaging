#!/bin/bash
set -e
name=p11-kit
homepage="https://p11-glue.freedesktop.org"
description="Loads and enumerates PKCS#11 modules"
repo=p11-glue/p11-kit
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(libtasn1 make-ca nss)
ghr_download "$repo" "$version" "$filename" 
unpk_enter "$filename" "$direname"
sed '20,$ d' -i trust/trust-extract-compat &&

cat >> trust/trust-extract-compat << "EOF"
# Copy existing anchor modifications to /etc/ssl/local
/usr/libexec/make-ca/copy-trust-modifications

# Update trust stores
/usr/sbin/make-ca -r
EOF
mni --prefix=/usr --buildtype=release -D trust_paths=/etc/pki/anchors
sudo ln -sfv /usr/libexec/p11-kit/trust-extract-compat \
        /usr/bin/update-ca-certificates
cd ../..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
