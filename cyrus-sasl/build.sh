#!/bin/bash
set -e
name=cyrus-sasl
repo="cyrusimap/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
blfs_depends=(lmdb)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/releases/download/$direname/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
gap_patches $name
sudo autoreconf -fiv
sudo chown $USER -R .
sed '/saslint/a #include <time.h>'       -i lib/saslutil.c &&
sed '/plugin_common/a #include <time.h>' -i plugins/cram.c
configure_options=(--prefix=/usr                       \
            --sysconfdir=/etc                   \
            --enable-auth-sasldb                \
            --with-dblib=lmdb                   \
            --with-dbpath=/var/lib/sasl/sasldb2 \
            --with-sphinx-build=no              \
	    --with-saslauthd=/var/run/saslauthd)
cmi "${configure_options[@]}"
sudo su -c "install -v -dm755                          /usr/share/doc/$direname/html &&
install -v -m644  saslauthd/LDAP_SASLAUTHD /usr/share/doc/$direname      &&
install -v -m644  doc/legacy/*.html        /usr/share/doc/$direname/html &&
install -v -dm700 /var/lib/sasl"
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
