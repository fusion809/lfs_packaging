#!/bin/bash
set -e
name=libmng
repo=LuaDist/$name
version=$(gh_ver $repo)
depends=(glibc lcms2 libjpeg-turbo zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://downloads.sourceforge.net/libmng/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --disable-static
sudo su -c "install -v -m755 -d        /usr/share/doc/$direname &&
install -v -m644 doc/*.txt /usr/share/doc/$direname"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
