#!/bin/bash
set -e
name=exempi
repo=libopenraw/$name
version=$(gfd_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(boost)
if ! [[ -f $filename ]]; then
	wget -c https://libopenraw.freedesktop.org/download/$filename 
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i -r '/^\s?testadobesdk/d' exempi/Makefile.am &&
sudo autoreconf -fiv
sudo chown $USER -R .
cmi --prefix=/usr --disable-static
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
