#!/bin/bash
set -e
name=nettle
version=$(gnu_ver nettle)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gnu_download $name $filename
rm -rf $direname
tar xf $filename
cd $direname
if ! [[ -f configure ]]; then
	autoreconf
fi
export PATH=$PATH:/opt/texlive/$(ls /opt/texlive/[0-9]* -ld | sed 's|.*/opt/texlive/||g')/bin/x86_64-linux
cmi --prefix=/usr --disable-static
sudo su -c "chmod   -v   755 /usr/lib/lib{hogweed,nettle}.so &&
install -v -m755 -d /usr/share/doc/$direname &&
install -v -m644 nettle.{html,pdf} /usr/share/doc/$direname"
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
