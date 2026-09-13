#!/bin/bash
set -e
name=gnupg
repo="gpg/$name"
version=$(gh_ver $repo)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
depends=(bzip2 cyrus-sasl glibc gmp gnutls libassuan libffi libgcrypt libgpg-error libidn2 libksba libtasn1 libunistring make-ca ncurses nettle npth openldap openssl p11-kit readline sqlite systemd zlib)
blfs_depends=(libusb)
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://www.gnupg.org/ftp/gcrypt/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
mkdir -p build
cd build
../configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc --docdir=/usr/share/doc/$direname
make -j$(nproc)
makeinfo --html --no-split -I doc -o doc/gnupg_nochunks.html ../doc/gnupg.texi &&
makeinfo --plaintext       -I doc -o doc/gnupg.txt           ../doc/gnupg.texi &&
make -C doc html
sudo su -c "make install &&

install -v -m755 -d /usr/share/doc/$direname/html            &&
install -v -m644    doc/gnupg_nochunks.html \
                    /usr/share/doc/$direname/html/gnupg.html &&
install -v -m644    ../doc/*.texi doc/gnupg.txt \
                    /usr/share/doc/$direname &&
install -v -m644    doc/gnupg.html/* \
                    /usr/share/doc/$direname/html"
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
