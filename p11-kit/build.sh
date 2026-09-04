#!/bin/bash
set -e
name=p11-kit
version=$(gh_ver p11-glue/p11-kit)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
blfs_depends=(make-ca libtasn1 nss)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/p11-glue/p11-kit/releases/download/$version/$filename 
fi
rm -rf $direname
tar xf $filename
cd $direname
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
