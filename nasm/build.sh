#!/bin/bash
set -e
name=nasm
repo="netwide-assembler/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
doc_filename="$name-$version-xdoc.tar.xz"
if ! [[ -f $filename ]]; then
	wget -c https://www.nasm.us/pub/nasm/releasebuilds/$version/$filename
fi
if ! [[ -f $doc_filename ]]; then
	wget -c https://www.nasm.us/pub/nasm/releasebuilds/$version/$doc_filename
fi
rm -rf $direname
tar xf $filename
cd $direname
tar -xf ../$doc_filename --strip-components=1
cmi --prefix=/usr
sudo su -c "install -m755 -d         /usr/share/doc/$direname/html  &&
cp -v doc/html/*.html    /usr/share/doc/$direname/html  &&
cp -v doc/*.{txt,ps,pdf} /usr/share/doc/$direname"
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
