#!/bin/bash
set -e
name=libcdio
version=$(gn_ver $name)
depends=(gcc glibc ncurses)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://ftpmirror.gnu.org/libcdio/$filename
fi
pr_url=$(wget -cqO- https://www.linuxfromscratch.org/blfs/view/systemd/multimedia/libcdio.html | grep "libcdio-paranoia" | cut -d '"' -f 2 | head -n 1)
pr_filename=$(echo $pr_url | sed 's|.*libcdio/||g')
pr_direname=$(echo $pr_filename | sed 's/.tar.*//g')
if ! [[ -f $pr_filename ]]; then
	wget -c $pr_url
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --disable-static
tar -xf ../$pr_filename &&
cd $pr_direname &&
cmi --prefix=/usr --disable-static &&
cd ../..
rm -rf "$filename" "$direname" "$pr_filename"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
