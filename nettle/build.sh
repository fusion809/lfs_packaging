#!/bin/bash
set -e
name=nettle
version=$(gnu_ver nettle)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
full_tag=$(timeout 5 git ls-remote --tags --refs https://github.com/gnutls/nettle.git | grep "refs/tags/nettle_4.0_.*" | cut -d '/' -f 3)
if ! ( [[ -f $filename ]] || [[ -f $full_tag.tar.gz ]] ) ; then
	wget -c https://ftpmirror.gnu.org/nettle/$filename || ( wget -c https://github.com/gnutls/nettle/archive/refs/tags/$full_tag.tar.gz)
fi
if [[ -f $full_tag.tar.gz ]]; then
	filename="$full_tag.tar.gz"
	direname="$name-$full_tag"
fi
rm -rf $direname
tar xf $filename
cd $direname
if ! [[ -f configure ]]; then
	autoreconf
fi
#if ( [[ -f /var/lib/book-packages/texlive ]] || [[ -f /var/lib/custom-packages/texlive ]] ); then
#	export PATH=$PATH:/opt/texlive/$(ls /opt/texlive/[0-9]* -ld | sed 's|.*/opt/texlive/||g')/bin/x86_64-linux
#	cmi --prefix=/usr --disable-static
#	sudo su -c "chmod   -v   755 /usr/lib/lib{hogweed,nettle}.so &&
#install -v -m755 -d /usr/share/doc/$direname &&
#install -v -m644 nettle.{html,pdf} /usr/share/doc/$direname"
#else
	cmi --prefix=/usr --disable-static --enable-documentation=no
	sudo su -c "chmod   -v   755 /usr/lib/lib{hogweed,nettle}.so"
#fi
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
