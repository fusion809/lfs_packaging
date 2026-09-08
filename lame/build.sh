#!/bin/bash
set -e
name=lame
repo=${name}project/$name
version=$(gh_ver $repo)
depends=(glibc ncurses)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://downloads.sourceforge.net/lame/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i -e 's/^\(\s*hardcode_libdir_flag_spec\s*=\).*/\1/' configure
./configure --prefix=/usr --disable-static --enable-mp3rtp
make -j$(nproc)
make pkghtmldir=/usr/share/doc/$direname install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
