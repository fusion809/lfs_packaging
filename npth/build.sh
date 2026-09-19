#!/bin/bash
set -e
name=npth
repo="gpg/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://www.gnupg.org/ftp/gcrypt/$name/$filename
fi
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
