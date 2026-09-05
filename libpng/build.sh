#!/bin/bash
set -e
name=libpng
repo=pnggroup/libpng
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
patch_filename="$name-$version-apng.patch.gz"
if ! [[ -f $filename ]]; then
	wget -c https://downloads.sourceforge.net/libpng/$filename
fi
if ! [[ -f $patch_filename ]]; then
	wget -c https://downloads.sourceforge.net/sourceforge/libpng-apng/$patch_filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
zcat ../$patch_filename | patch -p1
cmi --prefix=/usr --disable-static
sudo install -vDm644 README libpng-manual.txt -t /usr/share/doc/$filename
cd ..
rm -rf "$filename" "$direname" "$patch_filename"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
