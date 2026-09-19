#!/bin/bash
set -e
name=libcdio
version=$(gnu_ver $name)
depends=(gcc glibc ncurses)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
gnu_download $name $filename
pr_url=$(wget -cqO- https://www.linuxfromscratch.org/blfs/view/systemd/multimedia/libcdio.html | grep "libcdio-paranoia" | cut -d '"' -f 2 | head -n 1)
pr_filename=$(echo $pr_url | sed 's|.*libcdio/||g')
pr_direname=$(echo $pr_filename | sed 's/.tar.*//g')
download_src "$pr_url"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
tar -xf ../$pr_filename &&
cd $pr_direname &&
cmi --prefix=/usr --disable-static &&
cd ../..
rm -rf "$filename" "$direname" "$pr_filename"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
