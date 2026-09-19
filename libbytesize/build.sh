#!/bin/bash
set -e
name=libbytesize
repo="storaged-project/libbytesize"
version=$(gh_ver $repo)
depends=(glibc gmp mpfr pcre2)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/storaged-project/libbytesize/releases/download/$version/$filename
fi
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --with-gtk-doc=no
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
